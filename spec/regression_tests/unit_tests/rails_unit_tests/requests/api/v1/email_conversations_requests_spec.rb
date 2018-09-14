require 'rails_helper'

RSpec.describe Api::V1::EmailConversationsController, :type => :request do
  let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
  before(:each) do
    login gmail_account.user
  end

  describe ".show" do
    let!(:email_conversation) { FactoryGirl.create(:email_conversation, :email_account => gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, 2, :email_account => gmail_account, :email_conversation => email_conversation) }
    context 'when the user is NOT signed in' do
      before do
        get "/api/v1/email_conversations/#{email_conversation.id}"
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should show a conversation' do
        expect(EmailConversation).to receive(:find_by).with(:email_account => gmail_account.user.gmail_accounts.first,
                                                            :id => email_conversation.id.to_s).and_call_original

        get "/api/v1/email_conversations/#{email_conversation.id}"

        email_conversation_rendered = JSON.parse(response.body)
        validate_email_conversation(email_conversation, email_conversation_rendered)
      end

      it 'renders the api/v1/email_conversations/show rabl' do
        expect( get "/api/v1/email_conversations/#{email_conversation.id}" ).to render_template('api/v1/email_conversations/show')
      end

      context "when try to show other conversation" do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account) }
        let!(:email_conversation_other) { FactoryGirl.create(:email_conversation, :email_account => gmail_account_other) }

        it 'responds with the email conversation not found status code' do
          get "/api/v1/email_conversations/#{email_conversation_other.id}"

          expect(response.status).to eq($config.http_errors[:email_conversation_not_found][:status_code])
        end

        it 'returns the email conversation not found message' do
          get "/api/v1/email_conversations/#{email_conversation_other.id}"

          expect(response.body).to eq($config.http_errors[:email_conversation_not_found][:description])
        end
      end #__End of context "when try to show other conversation"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".show"__

  describe ".index" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/email_conversations/index'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:email_conversation) { FactoryGirl.create(:email_conversation, :email_account => gmail_account) }
      let!(:emails) { FactoryGirl.create_list(:email, 2, :email_account => gmail_account, :email_conversation => email_conversation) }

      context "when the user has their email account" do
        before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

        it "responds with 200 status code" do
          get '/api/v1/email_conversations'

          expect(response.status).to eq(200)
        end

        it 'renders the api/v1/email_conversations/index rabl' do
          expect( get '/api/v1/email_conversations' ).to render_template('api/v1/email_conversations/index')
        end
      end #__End of context "when the user has their email account"__

      context "when the user has no email account" do
        let!(:user) { FactoryGirl.create(:user) }
        before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

        it 'responds with the email account not found status code' do
          get '/api/v1/email_conversations'

          expect(response.status).to eq($config.http_errors[:email_account_not_found][:status_code])
        end

        it 'returns the email account not found message' do
          get '/api/v1/email_conversations'

          expect(response.body).to eq($config.http_errors[:email_account_not_found][:description])
        end
      end #__End of context "when the user has no email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__
end
