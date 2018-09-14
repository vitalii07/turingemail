require 'rails_helper'

RSpec.describe Api::V1::EmailTrackersController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe '.index' do
    let!(:user_with_gmail_accounts) { FactoryGirl.create(:user_with_gmail_accounts) }
    let!(:email_trackers) { FactoryGirl.create_list(:email_tracker, SpecMisc::MEDIUM_LIST_SIZE, :email_account => user_with_gmail_accounts.current_email_account()) }

    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/email_trackers'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', :email => user_with_gmail_accounts.email, :password => user_with_gmail_accounts.password }

      it 'returns the email trackers of the email account' do
        expect_any_instance_of(GmailAccount).to receive(:email_trackers).and_call_original

        get '/api/v1/email_trackers'
      end

      it 'responds with a 200 status code' do
        get '/api/v1/email_trackers'

        expect(response.status).to eq(200)
      end

      it 'renders the index rabl' do
        expect( get '/api/v1/email_trackers' ).to render_template(:index)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__
end
