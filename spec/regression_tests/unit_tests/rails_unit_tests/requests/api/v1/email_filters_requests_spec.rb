require 'rails_helper'

RSpec.describe Api::V1::EmailFiltersController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe '.create' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account, user: user) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, gmail_account: gmail_account) }
    let!(:email_filter_attributes) do
      FactoryGirl.attributes_for(:email_filter).
        merge(email_account_id: gmail_account.id).
        merge(email_folder_id: gmail_label.id, email_folder_type: "GmailLabel")
    end

    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_filters', email_filter: email_filter_attributes
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }

      before { post '/api/v1/api_sessions', email: user.email, password: user.password }

      it 'creates new email rule' do
        expect(EmailFilter).to receive(:create!)

        post '/api/v1/email_filters', email_filter: email_filter_attributes
      end

      it 'responds with a 200 status code' do
        post '/api/v1/email_filters', email_filter: email_filter_attributes

        expect(response.status).to eq(200)
      end

      it 'returns the created rule' do
        expect(post('/api/v1/email_filters',
                    email_filter: email_filter_attributes)).
          to render_template(:create)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".create"__

  describe '.index' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:gmail_account) { FactoryGirl.create(:gmail_account, user: user) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, gmail_account: gmail_account) }
    let!(:email_filters) { FactoryGirl.create_list(:email_filter, SpecMisc::MEDIUM_LIST_SIZE, email_account: gmail_account, email_folder: gmail_label) }

    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/email_filters'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', email: user.email, password: user.password }

      it 'returns the email rules of the current user' do
        expect_any_instance_of(User).to receive(:email_filters).and_call_original

        get '/api/v1/email_filters'
      end

      it 'responds with a 200 status code' do
        get '/api/v1/email_filters'

        expect(response.status).to eq(200)
      end

      it 'renders the index rabl' do
        expect( get '/api/v1/email_filters' ).to render_template(:index)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__

  describe '.destroy' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:gmail_account) { FactoryGirl.create(:gmail_account, user: user) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, gmail_account: gmail_account) }
    let!(:email_filter) { FactoryGirl.create(:email_filter, email_account: gmail_account, email_folder: gmail_label) }

    context 'when the user is NOT signed in' do
      before do
        delete "/api/v1/email_filters/#{email_filter.id}"
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', email: user.email, password: user.password }

      it 'destroys the email rule' do
        expect_any_instance_of(EmailFilter).to receive(:destroy!)

        delete "/api/v1/email_filters/#{email_filter.id}"
      end

      it 'responds with a 200 status code' do
        delete "/api/v1/email_filters/#{email_filter.id}"

        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        delete "/api/v1/email_filters/#{email_filter.id}"

        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__

    context 'when the other user is signed in' do
      before { post '/api/v1/api_sessions', email: user_other.email, password: user_other.password }

      before do
        delete "/api/v1/email_filters/#{email_filter.id}"
      end

      it 'should respond with the email not found status code' do
        expect(response.status).to eq($config.http_errors[:email_filter_not_found][:status_code])
      end

      it 'should respond with the email not found message' do
        expect( response.body ).to eq( $config.http_errors[:email_filter_not_found][:description] )
      end
    end #__End of context "when the other user is signed in"__
  end #__End of describe ".destroy"__

  describe '.recommended_rules' do
    # Stub: currently unused
  end #__End of describe ".recommended_rules"__
end
