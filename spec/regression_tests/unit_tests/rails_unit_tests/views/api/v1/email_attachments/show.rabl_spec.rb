require 'rails_helper'

RSpec.describe 'api/v1/email_attachments/show', :type => :view do
  it 'should render a email_attachment' do
    email_attachment = assign(:email_attachment, FactoryGirl.create(:email_attachment))

    render

    email_attachment_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid
                             filename
                             file_url
                             from_subject
                             file_size
                             date
                             content_type
                             from_address)
    expected_attributes_to_skip = %w(from_subject date from_address)

    spec_validate_attributes(expected_attributes, email_attachment, email_attachment_rendered, expected_attributes_to_skip)
  end
end
