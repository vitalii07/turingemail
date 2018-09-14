class Api::V1::EmailTrackersController < ApiController
  before_action :authenticate_user!
  before_action do
    render_authentication_message(true)
  end

  before_action :set_email_account

  swagger_controller :email_trackers, 'Email Trackers Controller'

  # :nocov:
  swagger_api :index do
    summary 'Return email trackers.'

    response :ok
  end
  # :nocov:

  def index
    @email_trackers = @email_account.email_trackers.
                                     includes(:email_tracker_recipients => :email_tracker_views).
                                     order(:email_date => :desc)
  end
end
