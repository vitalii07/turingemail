require 'rails_helper'

RSpec.describe 'api/v1/inbox_cleaner_rules/show', :type => :view do
  it 'returns the inbox cleaner rule' do
    inbox_cleaner_rule = assign(:inbox_cleaner_rule, FactoryGirl.create(:inbox_cleaner_rule))
    render
    inbox_cleaner_rule_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid from_address to_address subject list_id)
    spec_validate_attributes(expected_attributes, inbox_cleaner_rule, inbox_cleaner_rule_rendered)
  end
end
