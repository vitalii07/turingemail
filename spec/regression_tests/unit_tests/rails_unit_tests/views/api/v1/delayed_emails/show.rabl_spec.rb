require 'rails_helper'

RSpec.describe 'api/v1/delayed_emails/show', :type => :view do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }
  # let!(:delayed_job) { Delayed::Job.create(handler: "test handler", run_at: Time.now) }

  it 'should render a delayed_email' do
    delayed_email = assign(:delayed_email, FactoryGirl.create(:delayed_email, email_account: email_account))

    render

    delayed_email_rendered = JSON.parse(rendered)

    expected_attributes = %w(send_at
                             uid
                             tos
                             ccs
                             bccs
                             subject
                             html_part
                             text_part
                             email_in_reply_to_uid
                             tracking_enabled
                             reminder_enabled
                             reminder_time
                             reminder_type
                             attachment_s3_keys)
    expected_attributes_to_skip = %w(send_at)
    spec_validate_attributes(expected_attributes, delayed_email, delayed_email_rendered, expected_attributes_to_skip)
  end
end
