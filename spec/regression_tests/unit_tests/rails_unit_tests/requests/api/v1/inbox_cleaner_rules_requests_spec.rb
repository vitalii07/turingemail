require 'rails_helper'

RSpec.describe Api::V1::InboxCleanerRulesController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe '.create' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:list_id) { 'sales.turinginc.com' }
    let!(:destination_folder_name) { 'sales' }

    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/inbox_cleaner_rules', :list_id => list_id, :destination_folder_name => destination_folder_name
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

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'creates new inbox cleaner rule' do
        expect(InboxCleanerRule).to receive(:find_or_create_by!)

        post '/api/v1/inbox_cleaner_rules', :list_id => list_id, :destination_folder_name => destination_folder_name
      end

      it 'responds with a 200 status code' do
        post '/api/v1/inbox_cleaner_rules', :list_id => list_id, :destination_folder_name => destination_folder_name

        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        post '/api/v1/inbox_cleaner_rules', :list_id => list_id, :destination_folder_name => destination_folder_name

        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".create"__

  describe '.index' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:inbox_cleaner_rules) { FactoryGirl.create_list(:inbox_cleaner_rule, SpecMisc::MEDIUM_LIST_SIZE, :user => user) }

    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/inbox_cleaner_rules'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'returns the inbox cleaner rules of the current user' do
        expect_any_instance_of(User).to receive(:inbox_cleaner_rules).and_call_original

        get '/api/v1/inbox_cleaner_rules'
      end

      it 'responds with a 200 status code' do
        get '/api/v1/inbox_cleaner_rules'

        expect(response.status).to eq(200)
      end

      it 'renders the index rabl' do
        expect( get '/api/v1/inbox_cleaner_rules' ).to render_template(:index)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__

  describe '.destroy' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:inbox_cleaner_rule) { FactoryGirl.create(:inbox_cleaner_rule, :user => user) }

    context 'when the user is NOT signed in' do
      before do
        delete "/api/v1/inbox_cleaner_rules/#{inbox_cleaner_rule.uid}"
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'destroys the inbox cleaner rule' do
        expect_any_instance_of(InboxCleanerRule).to receive(:destroy!)

        delete "/api/v1/inbox_cleaner_rules/#{inbox_cleaner_rule.uid}"
      end

      it 'responds with a 200 status code' do
        delete "/api/v1/inbox_cleaner_rules/#{inbox_cleaner_rule.uid}"

        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        delete "/api/v1/inbox_cleaner_rules/#{inbox_cleaner_rule.uid}"

        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__

    context 'when the other user is signed in' do
      before { post '/api/v1/api_sessions', :email => user_other.email, :password => user_other.password }

      before do
        delete "/api/v1/inbox_cleaner_rules/#{inbox_cleaner_rule.uid}"
      end

      it 'should respond with the inbox cleaner rule not found status code' do
        expect(response.status).to eq($config.http_errors[:inbox_cleaner_rule_not_found][:status_code])
      end

      it 'should respond with the inbox cleaner rule not found message' do
        expect( response.body ).to eq( $config.http_errors[:inbox_cleaner_rule_not_found][:description] )
      end
    end #__End of context "when the other user is signed in"__
  end #__End of describe ".destroy"__
end
