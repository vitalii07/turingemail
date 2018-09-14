class Api::V1::EmailConversationsController < ApiController
  before_action :authenticate_user!
  before_action do
    render_authentication_message(true)
  end

  before_action :correct_user, only: :show
  before_action :set_email_account

  swagger_controller :email_conversations, "Email Conversations Controller"

  # :nocov:
  swagger_api :index do
    summary "Return list of email conversations."

    param :query, :page, :integer, :optional, "Conversations page"
    param :query, :search_query, :string, :optional, 'Contact search query'

    response :ok
  end
  # :nocov:

  def index
    if params[:search_query].present?
      @email_conversations =
        EmailConversation.search(@email_account, params[:search_query]).
            preload(:persons).
            page(params[:page]).per(25)
    else
      @email_conversations = @email_account.email_conversations.page(params[:page]).per(25)
    end

    render "api/v1/email_conversations/index"
  end

  # :nocov:
  swagger_api :show do
    summary "Return email conversation."

    param :path, :id, :integer, :required, "Email Conversation ID"
    param :query, :page, :integer, :optional, "Emails page"

    response :ok
    response $config.http_errors[:email_conversation_not_found][:status_code],
             $config.http_errors[:email_conversation_not_found][:description]
  end
  # :nocov:

  def show
  end

  private

  # Before filters

  def correct_user
    @email_conversation =
      EmailConversation.
      find_by(email_account: current_email_account, id: params[:id])

    if @email_conversation.nil?
      error = $config.http_errors[:email_conversation_not_found]
      render(status: error[:status_code], json: error[:description])
      return
    end
  end
end
