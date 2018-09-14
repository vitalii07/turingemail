require 'rails_helper'

RSpec.describe 'api/v1/email_conversations/index', :type => :view do
  it 'should render the email conversations' do
    email_conversations = assign(:email_conversations, FactoryGirl.create_list(:email_conversation, SpecMisc::MEDIUM_LIST_SIZE))

    email_conversations.each do |email_conversation|
      FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_conversation => email_conversation)
      FactoryGirl.create_list(:person, SpecMisc::MEDIUM_LIST_SIZE)
    end

    render

    email_conversations_rendered = JSON.parse(rendered)

    email_conversations.zip(email_conversations_rendered).each do |email_conversation, email_conversation_rendered|
      validate_email_conversation(email_conversation, email_conversation_rendered, true)
    end
  end
end
