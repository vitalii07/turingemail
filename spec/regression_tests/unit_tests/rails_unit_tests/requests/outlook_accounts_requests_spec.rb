require 'rails_helper'
require 'stringio'

RSpec.describe OutlookAccountsController, :type => :request do
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
          get "/outlook_oauth2_callback", params
          expect(flash[:danger]).to eq(I18n.t('email.access_not_granted'))
        end
      end

      it 'produces the default error message' do
        get "/outlook_oauth2_callback"
        expect(flash[:danger]).to eq(I18n.t(:error_message_default).html_safe)
      end

      it 'responses with 302 status code' do
        get "/outlook_oauth2_callback"
        expect(response.status).to eq(302)
      end

      it 'redirects to the root' do
        get "/outlook_oauth2_callback"
        expect(response).to redirect_to root_url
      end
    end #__End of describe "when the error params exists or code params is nil"__

    context "when the code params exists" do
      let!(:outlook_account) { FactoryGirl.create(:outlook_account) }
      before(:each) do
        user.outlook_accounts << outlook_account
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
        before { post '/api/v1/api_sessions', :email => outlook_account.user.email, :password => outlook_account.user.password }

        it 'signed out' do
          expect_any_instance_of(UserAuthKey).to receive(:destroy)
          get "/outlook_oauth2_callback", params
        end
      end #__End of describe "when the user is already signed in"__

      it 'gets the api client with the code params' do
        expect_any_instance_of(OutlookAccountsController).to receive(:get_api_client).with(params[:code])
        get "/outlook_oauth2_callback", params
      end

      context "when it gets the api client" do
        it 'creates the outlook OAuth2Client' do
          expect(Outlook::OAuth2Client).to receive(:base_client)
          get "/outlook_oauth2_callback", params
        end

        it 'fetches the access token by the outlook OAuth2Client' do
          expect_any_instance_of(Signet::OAuth2::Client).to receive(:fetch_access_token!)
          get "/outlook_oauth2_callback", params
        end

        it 'creates the OutlookOAuth2Token' do
          expect(OutlookOAuth2Token).to receive(:new)
          get "/outlook_oauth2_callback", params
        end

        it 'updates the OutlookOAuth2Token by the outlook OAuth2Client' do
          expect_any_instance_of(OutlookOAuth2Token).to receive(:update)
          get "/outlook_oauth2_callback", params
        end
      end #__End of describe "when it gets the api client"__

      context "when fails to get the api client" do
        it 'produces the default error message' do
          get "/outlook_oauth2_callback", params
          expect(flash[:danger]).to eq(I18n.t(:error_message_default).html_safe)
        end
      end #__End of context "when fails to get the api client"__

      it 'redirects to the mail url' do
        get "/outlook_oauth2_callback", params
        expect(response).to redirect_to signup_accounts_url
      end
    end #__End of describe "when the code params exists"__
  end #__End of describe ".o_auth2_callback"__
end
