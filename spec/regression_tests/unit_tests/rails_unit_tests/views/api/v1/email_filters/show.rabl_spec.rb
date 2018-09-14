require 'rails_helper'

RSpec.describe 'api/v1/email_filters/show', :type => :view do
  let!(:an_email_account) { FactoryGirl.create(:gmail_account) }
  let!(:imap_folder) { FactoryGirl.create(:imap_folder) }

  it 'returns the email rule' do
    email_filter = assign(:email_filter, FactoryGirl.create(:email_filter, :email_account => an_email_account, :email_folder => imap_folder))
    render
    email_filter_rendered = JSON.parse(rendered)

    expected_attributes = %w(email_account
    												 email_account_id email_account_type email_addresses
    												 email_folder email_folder_id email_folder_type id words)

		expected_attributes_to_skip = %w(email_account email_folder)
    spec_validate_attributes(expected_attributes, email_filter, email_filter_rendered, expected_attributes_to_skip)
  end
end
