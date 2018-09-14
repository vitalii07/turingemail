require 'rails_helper'

RSpec.describe 'api/v1/users/show', :type => :view do
  it 'should render the user' do
    user = assign(:user, FactoryGirl.create(:user))
    render
    user_rendered = JSON.parse(rendered)

    expected_attributes = %w(email email_accounts family_name given_name name num_emails profile_picture gender)
    expected_attributes_to_skip = %w(email_accounts num_emails)

    spec_validate_attributes(expected_attributes, user, user_rendered, expected_attributes_to_skip)
    expect(user_rendered["num_emails"]).to eq(user.emails.count)
  end
end
