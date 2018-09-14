class EmailAccountsController < ApplicationController
  before_action :authenticate_user!

  def get_api_client(code)
    o_auth2_base_client = get_o_auth2_base_client()
    o_auth2_base_client.code = code
    o_auth2_base_client.fetch_access_token!()

    # don't save because no GmailAccount yet to set to required api attribute.
    o_auth2_token = self.class::O_AUTH2_TOKEN_CLASS.new()
    o_auth2_token.update(o_auth2_base_client, false)

    return o_auth2_token, o_auth2_token.api_client(), o_auth2_base_client
  end

  def o_auth2_callback
    error = params[:error]
    code = params[:code]

    if error || code.nil?
      if error == 'access_denied'
        flash[:danger] = I18n.t('email.access_not_granted')
      else
        flash[:danger] = I18n.t(:error_message_default).html_safe
      end

      redirect_to(root_url)
    else
      new_user = false

      token = nil
      email_account = nil
      created_email_account = false

      begin
        sign_out_from_api() if current_user_with_user_auth_keys

        o_auth2_token, api_client, o_auth2_base_client = self.get_api_client(code)

        userinfo_data = self.class::EMAIL_ACCOUNT_CLASS.get_userinfo(api_client)
        email_account = self.class::EMAIL_ACCOUNT_CLASS.find_by(service_id: userinfo_data['id'], service_type: self.class::SERVICE_TYPE)

        #This will check if the current email account being logged in Exists And if it exists within current User's email accounts

        #Even if the current email account exists, but with another User's id
        #it will still continue to create one with the current users ID
        if email_account && current_user.email_accounts.pluck(:email).include?(email_account.email)
          log_console("FOUND email_account=#{email_account.email}")
          user = email_account.user
          if user.profile_picture != userinfo_data['picture']
            user.profile_picture = userinfo_data['picture']
            user.save!
          else
            user.touch #update user updated_at attribute anyway.
          end
          email_account.update(:last_sign_in_at => Time.now)

          if o_auth2_token.refresh_token.blank?
            begin
              email_account.o_auth2_token.refresh(nil, true)
            rescue Signet::AuthorizationError
              log_console("BAD!!! refresh token - redirecting to email login!!!")
              redirect_to_o_auth2_url()
              return
            end
          end

          email_account.o_auth2_token.update(o_auth2_base_client, true)
        else
          log_console("NOT FOUND email_account!!!")
          new_user = true
          created_email_account = true

          if o_auth2_token.refresh_token.blank?
            log_console("NO refresh token - redirecting to email login!!!")
            redirect_to_o_auth2_url()
            return
          end

          #This used to create a new User everytime, but now it just refers to the current user :)
          user = User.where(:id => current_user.id).first
          user.profile_picture = userinfo_data['picture']
          user.name            = userinfo_data['name']
          user.given_name      = userinfo_data['given_name']
          user.family_name     = userinfo_data['family_name']
          user.gender          = userinfo_data['gender']
          user.save!

          email_account = self.class::EMAIL_ACCOUNT_CLASS.new()
          email_account.user = user

          user.with_lock do
            email_account.refresh_user_info(api_client)

            o_auth2_token.api = email_account
            o_auth2_token.save!

            email_account.o_auth2_token = o_auth2_token
            email_account.last_sign_in_at = Time.now
            email_account.save!
          end
        end
        add_user_auth_keys_to_current_user(user)

        email_account.delay.sync_contacts(o_auth2_base_client.access_token)

        if created_email_account
          job_id = SyncAccountJob.perform_later(email_account.id).job_id
          email_account.set_job_uid!(job_id)
        end

        #flash[:success] = I18n.t('email.authenticated')
      rescue Exception => ex
        log_exception(false) { email_account.destroy! if created_email_account && email_account }
        log_exception(false) { token.destroy! if token }

        flash[:danger] = I18n.t(:error_message_default).html_safe
        log_email_exception(ex)
      end

      redirect_to("/signup_accounts")
    end
  end

  def o_auth2_remove
    current_user_with_user_auth_keys.with_lock do
      email_account = current_email_account
      if email_account
        email_account.delete_o_auth2_token()
        email_account.last_history_id_synced = nil
        email_account.save!
      end
    end

    flash[:success] = flash[:success] = I18n.t('email.unlinked')
    redirect_to(root_url)
  end

end
