require 'rails_helper'

RSpec.describe Api::V1::ApiSessionsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  context 'when the username and password is invalid' do
    let(:user) { FactoryGirl.build(:user) }

    it 'should not login the user' do
      post '/api/v1/api_sessions', :email => user.email, :password => user.password

      expect(response).to have_http_status(:unauthorized)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end



  context 'when the username and password is valid' do
    let(:user) { FactoryGirl.create(:user) }

    it 'should login the user' do
      post '/api/v1/api_sessions', :email => user.email, :password => user.password

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/users/show')
      expect(response.cookies['auth_key']).to_not eq(nil)
    end
  end

  context 'when the user is signed in' do
    let(:user) { FactoryGirl.create(:user) }
    before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

    it 'should logout the user' do
      delete '/api/v1/signout'

      expect(response).to have_http_status(:ok)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end

  context 'when there user is not signed in' do
    it 'logout should still succeed' do
      delete '/api/v1/signout'

      expect(response).to have_http_status(:ok)
      expect(response.cookies['auth_key']).to eq(nil)
    end
  end
end
