require 'rails_helper'

RSpec.describe Api::V1::UserConfigurationsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe '.show' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_configuration) { user.user_configuration }

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'shows the configuration of the current user' do
        expect_any_instance_of(User).to receive(:user_configuration).and_call_original

        get '/api/v1/user_configurations'
      end

      it 'responds with a 200 status code' do
        get '/api/v1/user_configurations'

        expect(response.status).to eq(200)
      end

      it 'renders the index rabl' do
        expect( get '/api/v1/user_configurations' ).to render_template(:show)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".show"__

  describe '.update' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_configuration) { user.user_configuration }

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'updates the configuration of the current user' do
        expect_any_instance_of(UserConfiguration).to receive(:update_attributes!).and_call_original

        patch '/api/v1/user_configurations'
      end

      it 'updates skin field' do
        expect(Skin).to receive(:find_by_uid).and_call_original

        patch '/api/v1/user_configurations'
      end

      it 'updates email_signature field' do
        expect(EmailSignature).to receive(:find_by_uid).and_call_original

        patch '/api/v1/user_configurations'
      end


      it 'responds with a 200 status code' do
        patch '/api/v1/user_configurations'

        expect(response.status).to eq(200)
      end

      it 'renders the show rabl' do
        expect( patch '/api/v1/user_configurations' ).to render_template('api/v1/user_configurations/show')
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".update"__


end