require 'rails_helper'

RSpec.describe Api::V1::WebsitePreviewsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end

  describe ".proxy" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/website_previews/proxy'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:params) {
        {
          :url => "https://google.com"
        }
      }

      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        get '/api/v1/website_previews/proxy', params
        expect(response.status).to eq(200)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".proxy"__
end
