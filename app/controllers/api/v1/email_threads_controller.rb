class Api::V1::EmailThreadsController < ApiController
  before_action :authenticate_user!
  before_action do
    render_authentication_message(true)
  end

  before_action :correct_user, :except => [:inbox, :in_folder, :retrieve, :move_to_folder, :apply_gmail_label,:remove_from_folder, :trash, :snooze]
  before_action :set_email_account
  before_action :filter_email_thread_uids, :only => [:move_to_folder, :apply_gmail_label, :remove_from_folder, :trash, :snooze]

  swagger_controller :email_threads, 'Email Threads Controller'

  # :nocov:
  swagger_api :inbox do
    summary 'Return email threads in the inbox.'

    param :query, :last_email_thread_uid, :string, :required, 'Last Email Thread UID'
    param :query, :dir, :string, :required, 'Query Direction'

    response :ok
  end
  # :nocov:

  def inbox
    if @email_account.class == GmailAccount or @email_account.class == ICloudMailAccount
      inbox_folder = GmailLabel.find_by(:gmail_account => @email_account, :label_id => "INBOX")
    else
      inbox_folder = ImapFolder.find_by(:email_account => @email_account, :name => "Inbox")
    end

    last_email_thread = EmailThread.find_by(:email_account => @email_account,
                                            :uid => params[:last_email_thread_uid])

    if inbox_folder.nil?
      @email_threads = []
    else
      @email_threads = EmailFolder.get_sorted_paginated_threads(email_folder: inbox_folder, last_email_thread: last_email_thread, dir: params[:dir], threads_per_page: 30)
    end

    render 'api/v1/email_threads/index'
  end

  # :nocov:
  swagger_api :in_folder do
    summary 'Return email threads in folder.'

    param :query, :folder_id, :string, :required, 'Email Folder ID'
    param :query, :last_email_thread_uid, :string, :required, 'Last Email Thread UID'
    param :query, :dir, :string, :required, 'Query Direction'

    response :ok
    response $config.http_errors[:email_folder_not_found][:status_code],
             $config.http_errors[:email_folder_not_found][:description]
  end
  # :nocov:

  def in_folder
    email_folder = @email_account.find_email_folder(params[:folder_id])

    last_email_thread = EmailThread.find_by(:email_account => @email_account,
                                            :uid => params[:last_email_thread_uid])

    if email_folder.nil?
      render :status => $config.http_errors[:email_folder_not_found][:status_code],
             :json => $config.http_errors[:email_folder_not_found][:description]
      return
    end

    @email_threads = EmailFolder.get_sorted_paginated_threads(email_folder: email_folder, last_email_thread: last_email_thread, dir: params[:dir], threads_per_page: 30)

    render 'api/v1/email_threads/index'
  end

  # :nocov:
  swagger_api :show do
    summary 'Return email thread.'

    param :path, :email_thread_uid, :string, :required, 'Email Thread UID'
    param :query, :page, :integer, :optional, 'Emails page'

    response :ok
    response $config.http_errors[:email_thread_not_found][:status_code],
             $config.http_errors[:email_thread_not_found][:description]
  end
  # :nocov:

  def show
  end

  # :nocov:
  swagger_api :stats do
    summary 'Return email thread stats.'

    param :path, :email_thread_uid, :string, :required, 'Email Thread UID'

    response :ok
    response $config.http_errors[:email_thread_not_found][:status_code],
             $config.http_errors[:email_thread_not_found][:description]
  end
  # :nocov:

  def stats
    emails = @email_thread.emails

    #Word count
    email_thread_word_count = 0
    emails.each do |email|
      if email.text_part
        email_thread_word_count += email.text_part.split(" ").length
      end
    end

    @word_count = email_thread_word_count

    #Num addresses:
    addresses = []
    emails.each do |email|
      addresses.push email.from_address
      if email.tos
        tos = email.tos.split(",")
        tos.each do |to|
          addresses.push to
        end
      end
      if email.ccs
        ccs = email.ccs.split(",")
        ccs.each do |cc|
          addresses.push cc
        end
      end
      if email.bccs
        bccs = email.bccs.split(",")
        bccs.each do |bcc|
          addresses.push bcc
        end
      end
    end

    @num_addresses = addresses.uniq.length

    # #Most common word
    @most_common_word = ""
    words = []
    emails.each do |email|
      if email.text_part
        text_part = email.text_part.gsub(/[^0-9a-z ]/i, '')
        words += text_part.split(" ")
      end
    end
    if words.length > 0
      most_common_word = most_common_value(words)
      @most_common_word += most_common_word.to_s
    end

    @email_thread_duration = ""
    #Duration
    if emails.size > 1
      num_hours = ((emails.first.date - emails.last.date) / 1.hour).round
      @email_thread_duration += num_hours.to_s + " hours"
    end

    subjects
  end

  # :nocov:
  swagger_api :subjects do
    summary 'Return recent email subjects.'

    param :path, :email_thread_uid, :string, :required, 'Email Thread UID'
    param :page_token, :email_thread_uid, :string, :optional, 'Page token'

    response :ok
    response $config.http_errors[:email_thread_not_found][:status_code],
             $config.http_errors[:email_thread_not_found][:description]
  end
  # :nocov:

  def subjects
    @recent_thread_subjects = { thread_subjects: [], next_page_token: nil }
    begin
      @recent_thread_subjects =
        current_email_account.recent_thread_subjects(@email_thread.emails.first.from_address, page_token: params[:page_token])
    rescue
      # For test environment
    end
  end

  # :nocov:
  swagger_api :retrieve do
    summary 'Get email threads.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'

    response :ok
  end
  # :nocov:

  def retrieve
    @email_threads = EmailThread.where(:email_account => @email_account, :uid => params[:email_thread_uids]).to_a()

    @email_threads.sort!() do |left, right|
      left_index = params[:email_thread_uids].find_index(left.uid)
      right_index = params[:email_thread_uids].find_index(right.uid)

      left_index <=> right_index
    end

    render 'api/v1/email_threads/index'
  end

  # :nocov:
  swagger_api :move_to_folder do
    summary 'Move the specified email threads to the specified folder.'
    notes 'If the folder name does not exist it is created.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :email_folder_id, :string, :required, 'Email Folder ID'
    param :form, :email_folder_name, :string, :required, 'Email Folder Name'

    response :ok
  end
  # :nocov:

  def move_to_folder
    emails = Email.where(:id => @email_ids)
    @gmail_label = @email_account.move_emails_to_folder(emails, folder_id: params[:email_folder_id],
                                                        folder_name: params[:email_folder_name])
    render 'api/v1/gmail_labels/show'
  end

  # :nocov:
  swagger_api :apply_gmail_label do
    summary 'Apply the specified Gmail Label to the specified email threads.'
    notes 'If the Gmail Label does not exist it is created.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :gmail_label_id, :string, :required, 'Gmail Label ID'
    param :form, :gmail_label_name, :string, :required, 'Gmail Label Name'

    response :ok
  end
  # :nocov:

  def apply_gmail_label
    emails = Email.where(:id => @email_ids)
    @gmail_label = @email_account.apply_label_to_emails(emails, label_id: params[:gmail_label_id],
                                                       label_name: params[:gmail_label_name])
    render 'api/v1/gmail_labels/show'
  end

  # :nocov:
  swagger_api :remove_from_folder do
    summary 'Remove the specified email threads from the specified folder.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :email_folder_id, :string, :required, 'Email Folder ID'

    response :ok
  end
  # :nocov:

  def remove_from_folder
    EmailAccount.sidekiq_delay.remove_emails_from_folder(@email_account.id, @email_ids, params[:email_folder_id])

    render :json => {}
  end

  # :nocov:
  swagger_api :trash do
    summary 'Move the specified email thread to the trash.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'

    response :ok
  end
  # :nocov:

  def trash
    EmailAccount.sidekiq_delay.trash_emails(@email_account.id, @email_ids)

    render :json => {}
  end

  # :nocov:
  swagger_api :snooze do
    summary 'Snooze the specified email threads.'

    param :form, :email_thread_uids, :string, :required, 'Email Thread UIDs'
    param :form, :minutes, :string, :required, 'Minutes to snooze'

    response :ok
  end
  # :nocov:

  def snooze
    minutes = params[:minutes].to_i.minutes

    emails = Email.where(:id => @email_ids)
    @email_account.remove_emails_from_folder(emails, folder_id: 'INBOX')
    @email_account.delay({:run_at => DateTime.now() + minutes}).wake_up(@email_ids)

    render :json => {}
  end

  private

  # Before filters

  def correct_user
    @email_thread = EmailThread.find_by(:email_account => current_email_account,
                                        :uid => params[:email_thread_uid])

    if @email_thread.nil?
      render :status => $config.http_errors[:email_thread_not_found][:status_code],
             :json => $config.http_errors[:email_thread_not_found][:description]
      return
    end
  end

  def filter_email_thread_uids
    @email_thread_ids = EmailThread.where(:email_account => @email_account, :uid => params[:email_thread_uids]).pluck(:id)
    @email_ids = Email.where(:email_account => @email_account, :email_thread_id => @email_thread_ids).pluck(:id)
  end
end
