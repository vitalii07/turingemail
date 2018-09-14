class Api::V1::EmailFiltersController < ApiController
  before_action :authenticate_user!
  before_action { render_authentication_message(true) }

  before_action :correct_user, except: [:create, :index, :recommended_filters]

  swagger_controller :email_filters, "Email Filters Controller"

  # :nocov:
  swagger_api :create do
    summary "Create an email filter."

    param :form, :email_addresses, :array, false, "Email Addresses"
    param :form, :words, :array, false, "Words"
    param :form, :email_account_id, :integer, false, "Email Account ID"
    param :form, :email_account_type, :string, false, "Email Account Type"
    param :form, :email_folder_id, :integer, false, "Email Folder ID"
    param :form, :email_folder_type, :string, false, "Email Folder Type"

    response :ok
  end
  # :nocov:

  def create
    @email_filter = EmailFilter.create!(email_filter_params)
  end

  # :nocov:
  swagger_api :update do
    summary "Update an email filter."

    param :path, :id, :string, :required, "Email Filter ID"

    param :form, :email_addresses, :array, false, "Email Addresses"
    param :form, :words, :array, false, "Words"
    param :form, :email_account_id, :integer, false, "Email Account ID"
    param :form, :email_account_type, :string, false, "Email Account Type"
    param :form, :email_folder_id, :integer, false, "Email Folder ID"
    param :form, :email_folder_type, :string, false, "Email Folder Type"

    response :ok
  end
  # :nocov:

  def update
    @email_filter.update_attributes! email_filter_params
  end

  # :nocov:
  swagger_api :index do
    summary "Return existing email filters."

    response :ok
  end
  # :nocov:

  def index
    @email_filters = current_user_with_user_auth_keys.email_filters
  end

  # :nocov:
  swagger_api :destroy do
    summary "Delete email filter."

    param :path, :id, :string, :required, "Email Filter ID"

    response :ok
  end
  # :nocov:

  def destroy
    @email_filter.destroy!

    render :json => {}
  end

  # :nocov:
  swagger_api :recommended_filters do
    summary "Return recommended filters for the current user."

    response :ok
  end
  # :nocov:

  def recommended_filters
    lists_email_daily_average =
      Email.lists_email_daily_average(current_user_with_user_auth_keys,
                                      where: ["auto_filed=?", true])

    filters_recommended = []

    lists_email_daily_average.each do |list_name, list_id, average|
      break if average < $config.recommended_filters_average_daily_list_volume
      next if current_user_with_user_auth_keys.email_filters.where(:list_id => list_id).count > 0

      subfolder = list_name
      subfolder = list_id if subfolder.nil?

      filters_recommended << { :list_id => list_id, :destination_folder_name => "List Emails/#{subfolder}" }
    end

    render json: { filters_recommended: filters_recommended }
  end

  private

  def email_filter_params
    params.
      require(:email_filter).
      permit(:email_account_id,
             :email_account_type,
             :email_folder_id,
             :email_folder_type,
             email_addresses: [],
             words: [])
  end

  # Before filters

  def correct_user
    @email_filter =
      current_user_with_user_auth_keys.email_filters.find_by(id: params[:id])

    if @email_filter.nil?
      render status: $config.http_errors[:email_filter_not_found][:status_code],
             json: $config.http_errors[:email_filter_not_found][:description]
      return
    end
  end
end
