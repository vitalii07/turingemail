class Api::V1::EmailAccountsController < ApiController
  before_action :authenticate_user!
  before_action do
    render_authentication_message(true)
  end

  before_action :set_email_account

  swagger_controller :email_accounts, 'Email Accounts Controller'

  # :nocov:
  swagger_api :send_email do
    summary 'Send an email.'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    param :form, :tracking_enabled, :boolean, false, 'Tracking Enabled'

    param :form, :reminder_enabled, :boolean, false, 'Reminder Enabled'
    param :form, :reminder_time, :string, false, 'Reminder Time'
    param :form, :reminder_type, :string, false, 'Reminder Type'

    param :form, :attachment_s3_keys, :string, false, 'Array of attachment s3 keys'

    response :ok
  end
  # :nocov:

  def send_email
    EmailSenderJob.perform_async(@email_account.id, nil, [params[:tos], params[:ccs], params[:bccs],
                                      params[:subject], params[:html_part], params[:text_part],
                                      params[:email_in_reply_to_uid],
                                      params[:tracking_enabled].andand.downcase == 'true',
                                      params[:reminder_enabled].andand.downcase == 'true', params[:reminder_time], params[:reminder_type],
                                      params[:attachment_s3_keys]])
    render :json => {}
  end

  # :nocov:
  swagger_api :send_email_delayed do
    summary 'Send email delayed.'

    param :form, :sendAtDateTime, :string, false, 'Datetime to send the email'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    param :form, :tracking_enabled, :boolean, false, 'Tracking Enabled'

    param :form, :reminder_enabled, :boolean, false, 'Reminder Enabled'
    param :form, :reminder_time, :string, false, 'Reminder Time'
    param :form, :reminder_type, :string, false, 'Reminder Type'

    param :form, :attachment_s3_keys, :string, false, 'Array of attachment s3 keys'

    response :ok
  end
  # :nocov:

  def send_email_delayed
    @email_account.with_lock do
      delayed_email = DelayedEmail.new
      delayed_email.email_account = @email_account

      delayed_email.tos = params[:tos]
      delayed_email.ccs = params[:ccs]
      delayed_email.bccs = params[:bccs]

      delayed_email.subject = params[:subject]

      delayed_email.html_part = params[:html_part]
      delayed_email.text_part = params[:text_part]

      delayed_email.email_in_reply_to_uid = params[:email_in_reply_to_uid]

      delayed_email.tracking_enabled = params[:tracking_enabled]

      delayed_email.reminder_enabled = params[:reminder_enabled].downcase == 'true'
      delayed_email.reminder_time = params[:reminder_time]
      delayed_email.reminder_type = params[:reminder_type]

      delayed_email.attachment_s3_keys = params[:attachment_s3_keys]

      delayed_email.save!

      delayed_email.send_and_destroy_at(params[:sendAtDateTime])

      @delayed_email = delayed_email
    end

    @email_account.delete_draft(params[:draft_id]) if params[:draft_id]

    render "api/v1/delayed_emails/show"
  end

  # :nocov:
  swagger_api :sync do
    summary 'Queues email sync.'

    response :ok
  end
  # :nocov:

  def sync
    @email_account.sync_account_unless_already_in_sync()
    render :json => @email_account.last_sync_at
  end

  # :nocov:
  swagger_api :search_threads do
    summary 'Search email threads using the same query format as the Gmail search box.'

    param :form, :query, :string, :required, 'Query - same query format as the Gmail search box.'
    param :form, :next_page_token, :string, false, 'Next Page Token - returned in a prior search_threads call.'

    response :ok
  end
  # :nocov:

  # TODO write tests
  def search_threads
    # email_thread_uids, @next_page_token = @email_account.search_threads(params[:query], params[:next_page_token])
    @email_threads = EmailThread.search_threads(@email_account.id, params[:query]).
        order_by_max_email_date.
        page(params[:next_page_token]).
        per(30).
        preload(latest_email: [:email_attachments, :email_attachment_uploads, :gmail_labels])
  end

  # :nocov:
  swagger_api :create_draft do
    summary 'Create email draft.'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :email_in_reply_to_uid, :string, false, 'Email UID being replied to.'

    param :form, :attachment_s3_keys, :string, false, 'Array of attachment s3 keys'

    response :ok
  end
  # :nocov:

  def create_draft
    @email = @email_account.create_draft(params[:tos], params[:ccs], params[:bccs],
                                         params[:subject], params[:html_part], params[:text_part],
                                         params[:email_in_reply_to_uid],
                                         params[:attachment_s3_keys])
    render 'api/v1/emails/show'
  end

  # :nocov:
  swagger_api :update_draft do
    summary 'Update email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    param :form, :tos, :string, false, 'Array of recipient email addresses'
    param :form, :ccs, :string, false, 'Array of recipient email addresses'
    param :form, :bccs, :string, false, 'Array of recipient email addresses'

    param :form, :subject, :string, false, 'Subject'
    param :form, :html_part, :string, false, 'HTML Part'
    param :form, :text_part, :string, false, 'Text Part'

    param :form, :attachment_s3_keys, :string, false, 'Array of attachment s3 keys'

    response :ok
  end
  # :nocov:

  def update_draft
    @email = @email_account.update_draft(params[:draft_id],
                                         params[:tos], params[:ccs], params[:bccs],
                                         params[:subject], params[:html_part], params[:text_part],
                                         params[:attachment_s3_keys])
    render 'api/v1/emails/show'
  end

  # :nocov:
  swagger_api :send_draft do
    summary 'Send email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    response :ok
  end
  # :nocov:

  def send_draft
    @email = @email_account.send_draft(params[:draft_id])

    render :json => {}
  end

  # :nocov:
  swagger_api :delete_draft do
    summary 'Delete email draft.'

    param :form, :draft_id, :string, :required, 'Draft ID'

    response :ok
  end
  # :nocov:

  def delete_draft
    @email_account.delete_draft(params[:draft_id])

    render :json => {}
  end

  # :nocov:
  swagger_api :cleaner_overview do
    summary 'Cleaner overview.'

    response :ok
  end
  # :nocov:

  def cleaner_overview
    @num_emails = @email_account.inbox_folder.andand.emails.size() || 0
    @report_date = @email_account.inbox_cleaner_report.andand.created_at
  end

  # :nocov:
  swagger_api :create_cleaner_report do
    summary 'Create cleaner report.'

    response :ok
  end
  # :nocov:

  def create_cleaner_report
    @email_account.inbox_cleaner_report.andand.destroy
    @email_account.create_inbox_cleaner_report
    @email_account.inbox_cleaner_report.delay.run

    render json: {}
  end

  # :nocov:
  swagger_api :destroy_cleaner_report do
    summary 'Destroy cleaner report.'

    response :ok
  end
  # :nocov:

  def destroy_cleaner_report
    @email_account.inbox_cleaner_report.andand.destroy

    render json: {}
  end

  # :nocov:
  swagger_api :cleaner_report do
    summary 'Cleaner report.'

    response :ok
  end
  # :nocov:

  def cleaner_report
    @cleaner_report = @email_account.inbox_cleaner_report
  end

  # :nocov:
  swagger_api :apply_cleaner do
    summary 'Apply cleaner.'

    param :form, :category, :string, false, 'Category of emails to archive'
    param :form, :before_date, :string, false, 'Archive emails before this date'
    param :form, :from_address, :string, false, 'Archive emails from this address'

    response :ok
  end
  # :nocov:

  def apply_cleaner
    emails = @email_account.inbox_folder.andand.emails.andand
    folder_name = "Archived"

    case params[:category].to_sym
    when :read
      scope = emails.inbox_cleaner_read
    when :calendar
      scope = emails.inbox_cleaner_calendar
      folder_name = "Archived/Calendar"
    when :auto_respond
      scope = emails.inbox_cleaner_auto_respond
      folder_name = "Archived/Auto-Respond"
    when :list
      scope = emails.inbox_cleaner_list
      folder_name = "Archived/List"
    when :before
      scope = emails.where "date < ?", DateTime.parse(params[:before_date])
    when :from
      scope = emails.where from_address: params[:from_address]
    end

    scope.andand.update_all auto_file_folder_name: folder_name

    @email_account.delay.apply_cleaner

    render :json => {}
  end

  # :nocov:
  swagger_api :get_token do
    summary 'Return the Email account OAuth2 token.'

    response :ok
  end
  # :nocov:

  def get_token
    @o_auth2_token = @email_account.o_auth2_token()
    @o_auth2_token.refresh()
    render 'api/v1/o_auth_2_tokens/show'
  end
end
