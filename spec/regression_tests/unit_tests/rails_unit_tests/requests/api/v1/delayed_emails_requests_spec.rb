require 'rails_helper'

RSpec.describe Api::V1::DelayedEmailsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe ".index" do
    let!(:email_account) { FactoryGirl.create(:gmail_account) }
    # let!(:delayed_job) { Delayed::Job.create(handler: "test handler", run_at: Time.now) }
    let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account) }

    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/delayed_emails'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      before { post '/api/v1/api_sessions', :email => email_account.user.email, :password => email_account.user.password }

      it 'renders all the delayed emails of the email account' do
        get '/api/v1/delayed_emails'

        returned_emails = JSON.parse(response.body)
        delayed_emails_count = returned_emails.count

        expect( delayed_emails_count ).to eq( email_account.delayed_emails.count )
      end

      it 'responds with a 200 status code' do
        get '/api/v1/delayed_emails'
        expect(response.status).to eq(200)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__

  describe ".destroy" do
    let!(:email_account) { FactoryGirl.create(:gmail_account) }
    # let!(:delayed_job) { Delayed::Job.create(handler: "test handler", run_at: Time.now) }
    let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account) }

    context 'when the user is NOT signed in' do
      before do
        delete "/api/v1/delayed_emails/#{delayed_email.uid}"
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      before { post '/api/v1/api_sessions', :email => email_account.user.email, :password => email_account.user.password }

      it 'destroys the delayed email' do
        expect_any_instance_of(DelayedEmail).to receive(:destroy!)

        delete "/api/v1/delayed_emails/#{delayed_email.uid}"
      end

      it 'responds with a 200 status code' do
        delete "/api/v1/delayed_emails/#{delayed_email.uid}"
        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        delete "/api/v1/delayed_emails/#{delayed_email.uid}"
        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".destroy"__
end
