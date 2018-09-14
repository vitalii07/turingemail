require 'rails_helper'

RSpec.describe Api::V1::SkinsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe '.index' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:skins) { FactoryGirl.create_list(:skin, SpecMisc::MEDIUM_LIST_SIZE) }

    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/skins'
      end

      it 'should response with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'renders all the skins' do
        expect(Skin).to receive(:all).and_call_original

        get '/api/v1/skins'
      end

      it 'responds with a 200 status code' do
        get '/api/v1/skins'

        expect(response.status).to eq(200)
      end

      it 'renders the index rabl' do
        expect( get '/api/v1/skins' ).to render_template(:index)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__
end
