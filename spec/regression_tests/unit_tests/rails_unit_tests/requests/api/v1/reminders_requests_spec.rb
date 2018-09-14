require 'rails_helper'

RSpec.describe Api::V1::RemindersController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  let(:gmail_account) { FactoryGirl.create :gmail_account, user: user }
  let!(:email) { FactoryGirl.create(:email, email_account: gmail_account, reminder_enabled: true, reminder_type: 'always', reminder_time: 2.days.from_now) }
  before(:each) do
    login user
  end
  before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

  context 'reminders' do
    it 'should list' do
      get '/api/v1/reminders'
      expect(response).to render_template('index')
    end

    context 'update reminder time' do
      it 'should save new time' do
        old_time = email.reminder_time
        post "/api/v1/reminders/#{email.id}/change_time", reminder_time: 5.days.from_now
        expect(response).to be_success
        expect(email.reload.reminder_time).not_to eq old_time
      end

      it 'should reject blank parameter' do
        expect{
          post "/api/v1/reminders/#{email.id}/change_time"
        }.to raise_error(ActionController::ParameterMissing)
      end

    end

    it 'should remove reminder' do
      put "/api/v1/reminders/#{email.id}"
      expect(response).to be_success
      expect(email.reload.reminder_enabled).to eq false
    end

  end
end
