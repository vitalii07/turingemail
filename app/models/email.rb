# == Schema Information
#
# Table name: emails
#
#  id                                :integer          not null, primary key
#  email_account_id                  :integer
#  email_account_type                :string
#  email_thread_id                   :integer
#  ip_info_id                        :integer
#  auto_filed                        :boolean          default(FALSE)
#  auto_filed_reported               :boolean          default(FALSE)
#  auto_filed_folder_id              :integer
#  auto_filed_folder_type            :string
#  uid                               :text
#  draft_id                          :text
#  message_id                        :text
#  list_name                         :text
#  list_id                           :text
#  seen                              :boolean          default(FALSE)
#  snippet                           :text
#  date                              :datetime
#  from_name                         :text
#  from_address                      :text
#  sender_name                       :text
#  sender_address                    :text
#  reply_to_name                     :text
#  reply_to_address                  :text
#  tos                               :text
#  ccs                               :text
#  bccs                              :text
#  subject                           :text             default("")
#  html_part                         :text             default("")
#  text_part                         :text             default("")
#  body_text                         :text             default("")
#  auto_file_folder_name             :string
#  queued_auto_file                  :boolean          default(FALSE)
#  has_calendar_attachment           :boolean          default(FALSE)
#  list_subscription_id              :integer
#  reminder_enabled                  :boolean          default(FALSE)
#  reminder_time                     :datetime
#  reminder_type                     :text
#  reminder_job_uid                  :string
#  upload_attachments_delayed_job_id :integer
#  attachments_uploaded              :boolean          default(FALSE)
#  created_at                        :datetime
#  updated_at                        :datetime
#  inbox_cleaner_data_id             :integer
#  email_conversation_id             :integer
#

require 'tmpdir'

class Email < ActiveRecord::Base
  #####################
  ### Relationships ###
  #####################

  belongs_to :email_account, polymorphic: true
  belongs_to :email_thread, counter_cache: true
  belongs_to :email_conversation, counter_cache: true

  belongs_to :ip_info

  belongs_to :auto_filed_folder, polymorphic: true

  belongs_to :inbox_cleaner_data, dependent: :destroy

  belongs_to :list_subscription

  has_many :email_folder_mappings,
           :dependent => :destroy
  has_many :imap_folders, :through => :email_folder_mappings, :source => :email_folder, :source_type => 'ImapFolder'
  has_many :gmail_labels, :through => :email_folder_mappings, :source => :email_folder, :source_type => 'GmailLabel'

  has_many :email_recipients,
           :dependent => :destroy

  has_many :people,
           :through => :email_recipients

  has_many :email_references,
           :dependent => :destroy

  has_many :email_in_reply_tos,
           :dependent => :destroy

  has_many :email_attachments,
           :dependent => :destroy

  has_many :email_tracker_recipients,
           :dependent => :destroy

  has_many :email_tracker_views,
           :through => :email_tracker_recipients

  has_many :email_attachment_uploads

  ##################
  ### Attributes ###
  ##################

  scope :inbox_cleaner_unprocessed,
        -> { where(inbox_cleaner_data_id: nil) }

  scope :inbox_cleaner_filter,
        -> (cond) { joins(:inbox_cleaner_data).where(inbox_cleaner_data: cond) }

  scope :inbox_cleaner_read,
        -> { where(seen: true) }

  scope :inbox_cleaner_calendar,
        -> { inbox_cleaner_filter(is_calendar: true) }

  scope :inbox_cleaner_list,
        -> { inbox_cleaner_filter(is_list: true) }

  scope :inbox_cleaner_auto_respond,
        -> { inbox_cleaner_filter(is_auto_respond: true) }

  scope :with_reminder, ->() { where(reminder_enabled: true)}

  attr_accessor :attachment_s3_keys

  enum :reminder_type => {
    :always => 'always',
    :not_opened => 'not_opened',
    :not_clicked => 'not_clicked',
    :no_reply => 'no_reply'
  }

  validates :email_account, :uid, :email_thread_id, presence: true

  after_create {
    EmailFolderMapping.where(:email_thread => self.email_thread).
                       update_all(:folder_email_thread_date => self.email_thread.emails.maximum(:date))
  }

  after_update {
    if self.seen_changed?
      self.gmail_labels.each do |gmail_label|
        gmail_label.update_num_unread_threads()
      end
    end
  }

  ###############
  ### Getters ###
  ###############

  def Email.lists_email_daily_average(user, limit: nil, where: nil)
    return user.emails.where("list_id IS NOT NULL").where(where).
                group(:list_name, :list_id).order('daily_average DESC').limit(limit).
                pluck('list_name, list_id, COUNT(*) / (1 + EXTRACT(day FROM now() - MIN(date))) AS daily_average')
  end

  def Email.get_sender_ip(email_raw)
    headers = parse_email_headers(email_raw.header.raw_source)
    headers.reverse!

    headers.each do |header|
      next if header.name.nil? || header.value.nil?

      if header.name.downcase == 'x-originating-ip'
        m = header.value.match(/\[(#{$config.ip_regex})\]/)

        if m
          #log_console("FOUND IP #{m[1]} IN X-Originating-IP=#{header.value}")
          return m[1]
        end
      elsif header.name.downcase == 'received'
        m = header.value.match(/from.*\[(#{$config.ip_regex})\]/)

        if m
          #log_console("FOUND IP #{m[1]} IN RECEIVED=#{header.value}")
          return m[1]
        end
      elsif header.name.downcase == 'received-spf'
        m = header.value.match(/client-ip=(#{$config.ip_regex})/)

        if m
          #log_console("FOUND IP #{m[1]} IN RECEIVED-SPF=#{header.value}")
          return m[1]
        end
      end
    end

    return nil
  end

  def user
    return self.email_account.user
  end

  def Email.part_has_calendar_attachment(part)
    return true if part.content_type =~ /text\/calendar|application\/ics/i

    part.parts.each do |current_part|
      return true if Email.part_has_calendar_attachment(current_part)
    end

    return false
  end

  def belongs_to_gmail_account?
    self.email_account.class == GmailAccount
  end

  def belongs_to_outlook_account?
    self.email_account.class == OutlookAccount
  end

  def has_contact_picture?
    self.contact_picture_url.present?
  end

  def contact_picture_url
    Person.find_by(email_address: from_address).andand.avatar_url
  end

  def imap_uid
    uid.sub(self.imap_folders.first.name, "").to_i
  end

  def get_email_in_reply_to_uid
    email_in_reply_to_uid = self.email_references.order(:position).last.email.uid if self.email_references.count > 0

    if email_in_reply_to_uid.nil?
      email_in_reply_to_uid = self.email_in_reply_tos.order(:position).last.email.uid if self.email_references.count > 0
    end
    return email_in_reply_to_uid
  end

  #################################
  ### Data Transforming Methods ###
  #################################

  def remove_reminder!
    self.reminder_enabled = false
    self.reminder_time = nil
    self.reminder_type = nil
    save
  end

  def Email.email_raw_from_params(tos = nil, ccs = nil, bccs = nil,
                                  subject = nil,
                                  html_part = nil, text_part = nil,
                                  email_account = nil, email_in_reply_to_uid = nil,
                                  attachment_s3_keys = [])
    attachment_s3_keys = [] if attachment_s3_keys.nil?

    email_raw = Mail.new do
      to tos
      cc ccs
      bcc bccs
      subject subject
    end

    email_raw.html_part = Mail::Part.new do
      content_type 'text/html; charset=UTF-8'
      body html_part
    end

    email_raw.text_part = Mail::Part.new do
      body text_part
    end

    email_in_reply_to = nil
    if !email_in_reply_to_uid.blank?
      email_in_reply_to = email_account.emails.includes(:email_thread).find_by(:uid => email_in_reply_to_uid)

      if email_in_reply_to
        log_console("FOUND email_in_reply_to=#{email_in_reply_to.id}")
        Email.add_reply_headers(email_raw, email_in_reply_to)
      end
    end

    s3_bucket = s3_get_bucket()

    attachment_s3_keys.each do |attachment_s3_key|
      object = s3_bucket.objects[attachment_s3_key]
      parts = attachment_s3_key.split(/\//)

      email_raw.add_file filename: parts[-1], content: object.read
    end

    return email_raw, email_in_reply_to
  end

  def Email.email_raw_from_mime_data(mime_data)
    mail_data_file = Tempfile.new($config.service_name_short.downcase)
    mail_data_file.binmode

    mail_data_file.write(mime_data)
    mail_data_file.close()
    email_raw = Mail.read(mail_data_file.path)
    FileUtils.remove_entry_secure(mail_data_file.path)

    return email_raw
  end

  def Email.email_from_mime_data(mime_data)
    email_raw = Email.email_raw_from_mime_data(mime_data)
    return Email.email_from_email_raw(email_raw)
  end

  def Email.email_from_email_raw(email_raw)
    email = Email.new

    ip = Email.get_sender_ip(email_raw)
    email.ip_info = IpInfo.find_latest_or_create_by_ip(ip) if ip

    email.message_id = email_raw.message_id

    if email_raw.header['List-ID']
      list_id_header_parsed = parse_email_list_id_header(email_raw.header['List-ID'])
      email.list_name = list_id_header_parsed[:name]
      email.list_id = list_id_header_parsed[:id]
    end

    email.date = email_raw.date

    froms_parsed = parse_email_address_field(email_raw, :from)
    if froms_parsed.length > 0
      email.from_name, email.from_address = froms_parsed[0][:display_name], froms_parsed[0][:address]
    end

    senders_parsed = parse_email_address_field(email_raw, :sender)
    if senders_parsed.length > 0
      email.sender_name, email.sender_address = senders_parsed[0][:display_name], senders_parsed[0][:address]
    end

    reply_tos_parsed = parse_email_address_field(email_raw, :reply_to)
    if reply_tos_parsed.length > 0
      email.reply_to_name, email.reply_to_address = reply_tos_parsed[0][:display_name], reply_tos_parsed[0][:address]
    end

    email.tos = email_raw.to.join('; ') if !email_raw.to.blank?
    email.ccs = email_raw.cc.join('; ') if !email_raw.cc.blank?
    email.bccs = email_raw.bcc.join('; ') if !email_raw.bcc.blank?
    email.subject = email_raw.subject.nil? ? '' : email_raw.subject

    email.text_part = email_raw.text_part.decoded.force_utf8(true) if email_raw.text_part
    email.html_part = premailer_html(email_raw.html_part.decoded).force_utf8(true) if email_raw.html_part

    if !email_raw.multipart? && (email_raw.content_type.nil? || email_raw.content_type =~ /text/i)
      email.body_text = premailer_html(email_raw.decoded.force_utf8(true)) if email_raw
    end

    email.has_calendar_attachment = Email.part_has_calendar_attachment(email_raw)

    Email.encode_email_in_utf8(email)

    return email
  end

  def Email.encode_email_in_utf8(email)
    email.from_name = email.from_name.encode("UTF-8") if email.from_name.present?
    email.from_address = email.from_address.encode("UTF-8") if email.from_address.present?
    email.reply_to_name = email.reply_to_name.encode("UTF-8") if email.reply_to_name.present?
    email.reply_to_address = email.reply_to_address.encode("UTF-8") if email.reply_to_address.present?
    email.tos = email.tos.encode("UTF-8") if email.tos.present?
    email.ccs = email.ccs.encode("UTF-8") if email.ccs.present?
    email.bccs = email.bccs.encode("UTF-8") if email.bccs.present?
    email.subject = email.subject.encode("UTF-8") if email.subject.present?
    email.body_text = email.body_text.encode("UTF-8") if email.body_text.present?
    email.html_part = email.html_part.encode("UTF-8") if email.html_part.present?
  end

  def Email.add_reply_headers(email_raw, email_in_reply_to)
    email_raw.in_reply_to = "<#{email_in_reply_to.message_id}>" if !email_in_reply_to.message_id.blank?

    references_header_string = ''

    reference_message_ids = email_in_reply_to.email_references.order(:position).pluck(:references_message_id)
    if reference_message_ids.length > 0
      log_console("reference_message_ids.length=#{reference_message_ids.length}")

      references_header_string = '<' + reference_message_ids.join("><") + '>'
    elsif email_in_reply_to.email_in_reply_tos.count == 1
      log_console("email_in_reply_tos.count=#{email_in_reply_to.email_in_reply_tos.count}")

      references_header_string =
          '<' + email_in_reply_to.email_in_reply_tos.first.in_reply_to_message_id + '>'
    end

    references_header_string << "<#{email_in_reply_to.message_id}>" if !email_in_reply_to.message_id.blank?

    log_console("references_header_string = #{references_header_string}")

    email_raw.references = references_header_string
  end

  def add_references(email_raw)
    return if email_raw.references.nil?

    if email_raw.references.class == String
      begin
        EmailReference.find_or_create_by!(:email => self, :references_message_id => email_raw.references,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end

      return
    end

    position = 0

    email_raw.references.each do |references_message_id|
      begin
        EmailReference.find_or_create_by!(:email => self, :references_message_id => references_message_id,
                                          :position => position)
      rescue ActiveRecord::RecordNotUnique
      end

      position += 1
    end
  end

  def add_in_reply_tos(email_raw)
    return if email_raw.in_reply_to.nil?

    if email_raw.in_reply_to.class == String
      begin
        EmailInReplyTo.find_or_create_by!(:email => self, :in_reply_to_message_id => email_raw.in_reply_to,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end

      return
    end

    position = 0

    email_raw.in_reply_to.each do |in_reply_to_message_id|
      begin
        EmailInReplyTo.find_or_create_by!(:email => self, :in_reply_to_message_id => in_reply_to_message_id,
                                          :position => 0)
      rescue ActiveRecord::RecordNotUnique
      end

      position += 1
    end
  end

  def add_recipients(email_raw)
    tos_parsed = parse_email_address_field(email_raw, :to)
    ccs_parsed = parse_email_address_field(email_raw, :cc)
    bccs_parsed = parse_email_address_field(email_raw, :bcc)

    tos_parsed.each { |to| self.add_recipient(to[:display_name], to[:address], EmailRecipient.recipient_types[:to]) }
    ccs_parsed.each { |cc| self.add_recipient(cc[:display_name], cc[:address], EmailRecipient.recipient_types[:cc]) }
    bccs_parsed.each { |bcc| self.add_recipient(bcc[:display_name], bcc[:address], EmailRecipient.recipient_types[:bcc]) }

    if (tos_parsed.size == 1) && (ccs_parsed.size == 0)
      self.add_to_conversation((tos_parsed.map {|to| to[:address]}) +
                               [self.from_address])
    end
  end

  def add_to_conversation(email_addresses)
    email_addresses.each do |email_address|
      if cleanse_email(email_address) != cleanse_email(self.email_account.email)
        person =
          Person.find_or_create_by!(email_account: self.email_account,
                                    email_address: cleanse_email(email_address))
        if person.email_conversations.blank?
          email_conversation =
            EmailConversation.create email_account: self.email_account
          person.email_conversations.push email_conversation
        end
        email_conversation = person.email_conversations.first
        email_conversation.emails.push self
        if !email_conversation.date || (self.date > email_conversation.date)
          email_conversation.date = self.date
        end
        email_conversation.save!
        break
      end
    end
  end

  def add_recipient(name, email_address, recipient_type)
    person = nil
    while person.nil?
      begin
        person = Person.find_or_create_by!(:email_account => self.email_account,
                                           :email_address => cleanse_email(email_address))
      rescue ActiveRecord::RecordNotUnique
      end
    end

    person.name = name
    person.save!

    email_recipient = nil
    while email_recipient.nil?
      begin
        email_recipient = EmailRecipient.find_or_create_by!(:email => self, :person => person,
                                                            :recipient_type => recipient_type)
      rescue ActiveRecord::RecordNotUnique
      end
    end
  end

  ################################
  ### Email Attachment Methods ###
  ################################

  def add_attachments(email_raw)
    if !email_raw.multipart? && email_raw.content_type && email_raw.content_type !~ /text/i
      self.add_attachment(email_raw)
    end

    email_raw.attachments.each do |attachment|
      self.add_attachment(attachment)
    end
  end

  def add_attachment(attachment)
    email_attachment = EmailAttachment.new email: self

    email_attachment.file_from_mail_part(attachment)
    email_attachment.save!
  end

  def get_attachments_from_gmail_data(gmail_client, parts_data, attachments = [])
    return attachments if parts_data.nil?

    gmail_client = self.email_account.gmail_client if gmail_client.nil?

    parts_data.each do |part|
      get_attachments_from_gmail_data(gmail_client, part['parts'], attachments)

      log_exception() do
        retry_block do
          if !part['filename'].blank? && part['body']
            email_attachment = EmailAttachment.new

            email_attachment.email = self
            email_attachment.filename = part['filename']
            email_attachment.mime_type = part['mimeType']

            if part['headers']
              part['headers'].each do |header|
                name = header['name'].downcase
                value = header['value']

                if name == 'content-type'
                  email_attachment.content_type = value.split(';')[0].downcase.strip
                elsif name == 'content-disposition'
                  email_attachment.content_disposition = value
                end
              end
            end

            body = part['body']

            if body['data']
              data = Base64.decode64(body['data'])
              email_attachment.file_size = data.length
              email_attachment.sha256_hex_digest = Digest::SHA256.hexdigest(data)
            else
              email_attachment.gmail_attachment_id = body['attachmentId']
              attachment_json = gmail_client.attachments_get('me', self.uid, email_attachment.gmail_attachment_id)

              data = Base64.urlsafe_decode64(attachment_json['data'])
              email_attachment.file_size = data.length
              email_attachment.sha256_hex_digest = Digest::SHA256.hexdigest(data)
            end

            email_attachment.s3_key = s3_get_new_key()

            file = Tempfile.new('turing')
            file.binmode
            file.write(data)
            file.close()

            file_info = {:content_type => email_attachment.content_type,
                         :content_disposition => email_attachment.content_disposition,
                         :s3_key => email_attachment.s3_key,
                         :file => file
            }
            s3_write_file(file_info)

            FileUtils.remove_entry_secure(file.path)

            attachments.push(email_attachment)
          end
        end
      end
    end

    return attachments
  end

  def upload_attachments
    email_account = self.email_account
    gmail_client = email_account.gmail_client

    new_email_attachments = []

    retry_block do
      gmail_data = gmail_client.messages_get('me', self.uid, format: 'full')
      new_email_attachments = self.get_attachments_from_gmail_data(gmail_client, gmail_data['payload']['parts'])
    end

    self.email_attachments.each do |old_attachment|
      new_email_attachments.each do |new_attachment|
        if old_attachment.sha256_hex_digest == new_attachment.sha256_hex_digest ||
           (old_attachment.sha256_hex_digest.nil? &&
            old_attachment.filename == new_attachment.filename &&
            old_attachment.file_size == new_attachment.file_size)
          new_attachment.uid = old_attachment.uid
        end
      end
    end

    ActiveRecord::Base.transaction do
      self.email_attachments.destroy_all()
      new_email_attachments.each { |email_attachment| email_attachment.save!() }
    end

    self.attachments_uploaded = true
    self.save!()
  end

  #############################
  ### Email Sending Methods ###
  #############################

  # Send actual email. called from EmailSenderJob worker.
  def self.send_email!(email_account_id, delayed_email_id, email_data=[])
    email_account = EmailAccount.find(email_account_id)
    tos, ccs, bccs, subject, html_part, text_part, email_in_reply_to_uid, tracking_enabled, reminder_enabled,
        reminder_time, reminder_type, attachment_s3_keys = email_data
    attachment_s3_keys = [] if attachment_s3_keys.nil?
    email_raw, email_in_reply_to = Email.email_raw_from_params(tos, ccs, bccs, subject, html_part, text_part,
                                                               email_account, email_in_reply_to_uid,
                                                               attachment_s3_keys)
    email = nil
    email_account.refresh_o_auth()
    email_raw.From = email_account.email
    email_raw.delivery_method.settings = {
        :enable_starttls_auto => true,
        :address              => email_account.smtp_address,
        :port                 => 587,
        :domain               => $config.smtp_helo_domain,
        :user_name            => email_account.email,
        :password             => email_account.smtp_password,
        :authentication       => email_account.smtp_authentication_type,
        :enable_starttls      => true
    }

    if tracking_enabled
      log_console('tracking_enabled = true!!!!!')

      html_part = '' if html_part.nil?

      email_message_ids = []
      sent_email_raws = []

      email_tracker = EmailTracker.new()
      email_tracker.uid = SecureRandom.uuid()
      email_tracker.email_account = email_account
      email_tracker.email_subject = subject
      email_tracker.email_date = DateTime.now()
      email_tracker.save!()

      email_recipients = [tos, ccs, bccs].flatten

      email_recipients.each do |rcpt_to|
        next if rcpt_to.blank?

        log_console("rcpt_to = #{rcpt_to}")

        email_tracker_recipient = EmailTrackerRecipient.new()
        email_tracker_recipient.email_tracker = email_tracker
        email_tracker_recipient.uid = SecureRandom.uuid()
        email_tracker_recipient.email_address = rcpt_to

        email_raw.html_part = Mail::Part.new do
          content_type 'text/html; charset=UTF-8'
          body html_part + "<img src=\"#{$url_helpers.confirmation_url(email_tracker_recipient.uid)}\" />"
        end

        email_raw.smtp_envelope_to = rcpt_to
        email_raw.message_id = nil

        retry_block do
          email_raw.deliver!
        end

        email_tracker_recipient.email = email
        email_tracker_recipient.save!()

        email_message_ids.push(email_raw.message_id)
        sent_email_raws.push(email_raw)
      end

      sent_email_raws.each { |sent_email_raw| email_account.sync_sent_email(sent_email_raw) }

      email_tracker.email_uids = []
      email_message_ids.each do |message_id|
        email = email_account.emails.find_by_message_id(message_id)
        email_tracker.email_uids.push(email.uid) if email
      end

      email_tracker.save!()
    else
      log_console('NO tracking_enabled')

      retry_block do
        email_raw.deliver!
      end

      email_account.sync_sent_email(email_raw)

      email = email_account.emails.find_by_message_id(email_raw.message_id)
    end
    if email && reminder_enabled
      log_console("REMINDER!! #{reminder_time} #{reminder_type}")
      email.reminder_enabled = reminder_enabled
      email.reminder_time = reminder_time
      email.reminder_type = reminder_type

      # we are running .send_email! method from sidekiq worker need schedule another job
      reminder_datetime = reminder_time.is_a?(String) ? DateTime.parse(reminder_time) : reminder_time
      job = Email.sidekiq_delay_until(reminder_datetime).run_reminder(email.id)
      email.reminder_job_uid = job

      email.save!
    end

    attachment_s3_keys.each do |attachment_s3_key|
      parts = attachment_s3_key.split(/\//)
      s3_key = parts[2]
      email_attachment_upload = email_account.user.email_attachment_uploads.find_by_s3_key(s3_key)
      log_exception() { email_attachment_upload.destroy!(); puts("DESTROYED ATTACHMENT: #{email_attachment_upload.id}") if email_attachment_upload }
    end

    # delete delayed_email after being sent
    if delayed_email_id
      delayed_email = DelayedEmail.find delayed_email_id
      delayed_email.destroy!
    end
  end

  ### Email Sending Methods - reminder

  # or by instance method  (object.run_reminder)
  # DO NOT use sidekiq_delay_until on instance objects
  # https://github.com/mperham/sidekiq/wiki/Delayed-extensions
  # this method is just to run simple tests in models/email_spec
  def run_reminder
    Email.run_reminder(self) # dont use self here becauseof issue in tests
  end

  # from sidekiq job(Email.sidekiq_delay_until..)
  def self.run_reminder(email_or_id)
    email = email_or_id.is_a?(Integer) ? Email.find(email_or_id) : email_or_id
    return if !email.reminder_enabled

    do_reminder = false
    if email.reminder_type == Email.reminder_types[:always]
      log_console('reminder ALWAYS!!')

      do_reminder = true
    elsif email.reminder_type == Email.reminder_types[:no_reply]
      log_console('reminder NO reply!!')

      if EmailInReplyTo.where(:email => email.email_account.emails, :in_reply_to_message_id => email.message_id).count == 0
        log_console('NO reply found!! doing reminder!!')

        do_reminder = true
      end
    elsif email.reminder_type == Email.reminder_types[:not_opened]
      log_console('reminder UNOPENED!!')

      if email.email_tracker_views.count == 0
        log_console('NO views found!! doing reminder!!')

        do_reminder = true
      end
    end

    email.email_account.apply_label_to_email(email, label_id: 'INBOX') if do_reminder
  end
end
