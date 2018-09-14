require 'rails_helper'

RSpec.describe Api::V1::GoogleContactsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:gmail_account) { FactoryGirl.create(:gmail_account, user: user) }
  let!(:google_contact) { FactoryGirl.create(:google_contact, email_account: gmail_account) }
  before(:each) do
    login user
  end

  before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

  it 'should render the contact with image' do
    url = 'http://static.comicvine.com/uploads/original/5/59300/4586078-5654268829-38709.jpg'
    uploaded_url = google_contact.upload_picture_from_url!(url)
    get '/api/v1/google_contacts/show', contact_email: google_contact.contact_email
    expect(response.body).not_to be blank?
  end

end
