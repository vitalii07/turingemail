require 'rails_helper'

RSpec.describe 'api/v1/email_conversations/show', :type => :view do
  it 'should render the email conversation' do
    email_conversation = assign(:email_conversation, FactoryGirl.create(:email_conversation))
    FactoryGirl.create_list(:email, SpecMisc::LARGE_LIST_SIZE, :email_conversation => email_conversation)

    render

    email_conversation_rendered = JSON.parse(rendered)
    validate_email_conversation(email_conversation, email_conversation_rendered)
  end
end
