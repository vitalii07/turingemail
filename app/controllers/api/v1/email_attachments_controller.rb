class Api::V1::EmailAttachmentsController < ApiController
  before_action :authenticate_user!
  before_action do
    render_authentication_message(true)
  end

  before_action :set_email_account

  swagger_controller :email_attachments, 'Email Attachments Controller'

  # :nocov:
  swagger_api :download do
    summary 'Download attachment.'

    param :path, :attachment_uid, :string, :required, 'Attachment UID'

    response :ok
  end
  # :nocov:

  def download
    email_attachment = @email_account.email_attachments.find_by_uid(params[:attachment_uid])
    if email_attachment.nil?
      render :status => $config.http_errors[:email_attachment_not_found][:status_code],
             :json => $config.http_errors[:email_attachment_not_found][:description]
      return
    end

    if email_attachment.file.present?
      render :json => {:url => email_attachment.file_url}
      return
    end

    email = email_attachment.email

    if email.attachments_uploaded
      render :json => {:url => s3_url(email_attachment.s3_key)}
    else
      job = Delayed::Job.find_by(:id => email.upload_attachments_delayed_job_id, :failed_at => nil)

      if job.nil?
        job = email.delay.upload_attachments()
        email.upload_attachments_delayed_job_id = job.id
        email.save!()
      end

      render :status => $config.http_errors[:email_attachment_not_ready][:status_code],
             :json => $config.http_errors[:email_attachment_not_ready][:description]
    end
  end

  # :nocov:
  swagger_api :index do
    summary 'Get all attachments for a user'

    param :query, :dir, :string, :optional, 'Query Direction'
    param_list :query, :order_by, :string, :optional, 'Order by Field', ['name', 'size', 'date']
    param_list :query, :type, :string, :optional, 'Filter Results by Type', ['image', 'document', 'other']
    param :query, :page, :integer, :optional, 'Email attachments page'

    response :ok
  end
  # :nocov:

  def index
    @email_attachments = EmailAttachment.order_and_filter(@email_account, params)
  end

  # :nocov:
  swagger_api :show do
    summary 'Fetch a single attachment.'

    param :path, :attachment_uid, :string, :required, 'Attachment UID'

    response :ok
  end
  # :nocov:

  def show
    @email_attachment = @email_account.email_attachments.find_by_uid(params[:attachment_uid])
    if @email_attachment.nil?
      render :status => $config.http_errors[:email_attachment_not_found][:status_code],
             :json => $config.http_errors[:email_attachment_not_found][:description]
      return
    end
  end

  # :nocov:
  swagger_api :destroy do
    summary 'Delete email attachment.'

    param :path, :attachment_uid, :string, :required, 'Attachment UID'

    response :ok
  end
  # :nocov:

  def destroy
    @email_attachment = @email_account.email_attachments.find_by_uid(params[:attachment_uid])
    if @email_attachment.nil?
      render :status => $config.http_errors[:email_attachment_not_found][:status_code],
             :json => $config.http_errors[:email_attachment_not_found][:description]
      return
    end

    @email_attachment.destroy!

    render :json => {}
  end
end