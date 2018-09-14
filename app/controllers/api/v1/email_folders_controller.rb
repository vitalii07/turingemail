class Api::V1::EmailFoldersController < ApiController
  before_action :authenticate_user!
  before_action do
    render_authentication_message(true)
  end

  swagger_controller :email_folders, 'Email Folders Controller'

  # :nocov:
  swagger_api :index do
    summary 'Return folders in current account.'

    response :ok
  end
  # :nocov:

  def index
    @email_folders = current_email_account.email_folders()

    render 'api/v1/email_folders/index'
  end
end
