require 'rails_helper'

RSpec.describe Api::V1::LogsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end

  it 'should log the message' do
    post '/api/v1/log'

    expect(response).to have_http_status(:ok)
  end
end
