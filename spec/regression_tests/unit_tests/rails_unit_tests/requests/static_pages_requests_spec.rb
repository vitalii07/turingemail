require 'rails_helper'

RSpec.describe StaticPagesController, :type => :request do
  describe ".landing" do
    it 'works' do
      get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2")
    end

    context 'when the user is NOT signed in' do
      it 'renders the landing page' do
        expect( get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2") ).to render_template("shared/_header_navbar")
        expect( get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2") ).to render_template("static_pages/homepage")
        expect( get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2") ).to render_template("layouts/landing")
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }

      before(:each) do
        login user
      end
      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      context 'and not signed in to a google account' do

        it 'redirects to the mail url' do
          get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2")

          expect(response).to redirect_to "/signup_accounts"
        end

      end

      context 'and signed in to a google account' do

        it 'redirects to the mail url' do
          get root_path, nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2")

          user.gmail_accounts << gmail_account

          expect( get '/mail', nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2") ).to render_template('static_pages/mail')
        end

      end

    end #__End of context "when the user is signed in"__

  end #__End of describe ".landing"__

  describe ".mail" do
    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      before(:each) do
        login user
      end
      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'renders the mail page' do
      	expect( get '/mail', nil, 'HTTP_AUTHORIZATION' => ActionController::HttpAuthentication::Basic.encode_credentials("turing", "email2") ).to render_template('static_pages/mail')
        # expect( get '/mail' ).to render_template('static_pages/mail')
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".mail"__

end
