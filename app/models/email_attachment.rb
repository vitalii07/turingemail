# == Schema Information
#
# Table name: email_attachments
#
#  id                  :integer          not null, primary key
#  email_id            :integer
#  filename            :text
#  content_type        :text
#  file_size           :integer
#  uid                 :text
#  mime_type           :text
#  content_disposition :text
#  sha256_hex_digest   :text
#  gmail_attachment_id :text
#  s3_key              :text
#  file                :text
#  created_at          :datetime
#  updated_at          :datetime
#

class EmailAttachment < ActiveRecord::Base
  belongs_to :email

  validates :uid, :email, :file_size, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }

  before_destroy {
    log_exception() do
      self.delay.s3_delete(self.s3_key) if !self.s3_key.blank?
    end
  }

  after_commit {
    MimeTypeMapping.find_or_create_by(mime_type: content_type)
  }

  mount_uploader :file, EmailAttachmentUploader

  delegate :url, to: :file, prefix: true

  # TODO: exists? method may cause delay because CW verify if the file exists in S3.
  def has_thumb?
    file.present? && file.thumb.file.try(:exists?)
  end

  def file_url(version = nil)
    file.url(version)
  end

  def self.order_and_filter(email_account, params)
    sort_dir = params[:dir] == "DESC" ? "DESC" : "ASC"

    if params[:order_by] == "name"
      order_by = "email_attachments.filename"
    elsif params[:order_by] == "size"
      order_by = "email_attachments.file_size"
    else
      order_by = "emails.date"
    end

    email_attachments = email_account.email_attachments.select(:uid, :filename, :file_size, :email_id, :content_type).order("#{order_by} #{sort_dir}").page(params[:page])

    unless params[:type].blank?
      mime_types = MimeTypeMapping.where(usable_category_cd: MimeTypeMapping.usable_categories[params[:type].to_sym])
      .pluck(:mime_type)
      email_attachments = email_attachments.where("content_type IN (?)", mime_types)
    end

    email_attachments.select(
        :uid,
        :filename,
        :file_size,
        :content_type,
        'emails.subject as email_subject',
        'emails.date as email_date',
        :file)
  end

  def file_from_mail_part(attachment)
    self.filename = attachment.filename
    if attachment.content_type
      self.content_type = attachment.content_type.split(';')[0].downcase.strip
    end

    tmp_file = Tempfile.new('turing')
    begin
      tmp_file.binmode
      tmp_file.write(attachment.decoded)

      self.file = tmp_file
    ensure
      tmp_file.close()
      FileUtils.remove_entry_secure(tmp_file.path)
    end
  end

  def self.search(account_id, query)
    rel = joins(:email).
      where(emails: {email_account_id: account_id})
    if query.present?
      rel = rel.where('filename ilike ?', '%' + query + '%')
    end
  end
end
