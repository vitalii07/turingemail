require 'rails_helper'
require 'stringio'

RSpec.describe YahooMailAccountsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe ".o_auth2_callback" do

    context "when the error params exists or code params is nil" do
      let!(:params) {
        {
          :error => 'access_denied'
        }
      }
      context "when the error is access_denied" do
        it 'produces the access not granted error message' do
          get "/yahoo_mail_oauth2_callback", params
          expect(flash[:danger]).to eq(I18n.t('email.access_not_granted'))
        end
      end

      it 'produces the default error message' do
        get "/yahoo_mail_oauth2_callback"
        expect(flash[:danger]).to eq(I18n.t(:error_message_default).html_safe)
      end

      it 'responses with 302 status code' do
        get "/yahoo_mail_oauth2_callback"
        expect(response.status).to eq(302)
      end

      it 'redirects to the root' do
        get "/yahoo_mail_oauth2_callback"
        expect(response).to redirect_to root_url
      end
    end #__End of describe "when the error params exists or code params is nil"__

    context "when the code params exists" do
      let!(:yahoo_mail_account) { FactoryGirl.create(:yahoo_mail_account) }
      before(:each) do
        user.yahoo_mail_accounts << yahoo_mail_account
      end
      let!(:params) {
        {
          :code => "example code"
        }
      }
      let!(:userinfo_data) {
       {
        'id' => 'user-id',
        'picture' => 'user-picture',
        'email' => 'user@email.com',
        'name' => 'user-name',
        'given_name' => 'user-given-name',
        'family_name' => 'user-family-name'
        }
      }

      before do
        allow_any_instance_of(Signet::OAuth2::Client).to receive(:fetch_access_token!)
      end

      context "when the user is already signed in" do
        before { post '/api/v1/api_sessions', :email => yahoo_mail_account.user.email, :password => yahoo_mail_account.user.password }

        it 'signed out' do
          expect_any_instance_of(UserAuthKey).to receive(:destroy)
          get "/yahoo_mail_oauth2_callback", params
        end
      end #__End of describe "when the user is already signed in"__

      it 'gets the api client with the code params' do
        expect_any_instance_of(YahooMailAccountsController).to receive(:get_api_client).with(params[:code])
        get "/yahoo_mail_oauth2_callback", params
      end

      context "when it gets the api client" do
        it 'creates the google OAuth2Client' do
          expect(YahooMail::OAuth2Client).to receive(:base_client)
          get "/yahoo_mail_oauth2_callback", params
        end

        it 'creates the YahooMailOAuth2Token' do
          expect(YahooMailOAuth2Token).to receive(:new)
          get "/yahoo_mail_oauth2_callback", params
        end

        it 'updates the YahooMailOAuth2Token by the google OAuth2Client' do
          expect_any_instance_of(YahooMailOAuth2Token).to receive(:update)
          get "/yahoo_mail_oauth2_callback", params
        end
      end #__End of describe "when it gets the api client"__

      context "when fails to get the api client" do
        it 'produces the default error message' do
          get "/yahoo_mail_oauth2_callback", params
          expect(flash[:danger]).to eq(I18n.t(:error_message_default).html_safe)
        end
      end #__End of context "when fails to get the api client"__

      it 'redirects to the mail url' do
        get "/yahoo_mail_oauth2_callback", params
        expect(response).to redirect_to signup_accounts_url
      end
    end #__End of describe "when the code params exists"__
  end #__End of describe ".o_auth2_callback"__
end
