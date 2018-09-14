require 'rails_helper'

RSpec.describe UsersController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
end
