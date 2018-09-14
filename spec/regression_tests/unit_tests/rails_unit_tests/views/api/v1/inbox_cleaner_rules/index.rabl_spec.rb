require 'rails_helper'

RSpec.describe 'api/v1/inbox_cleaner_rules/index', :type => :view do
  it 'returns the email rule' do
    inbox_cleaner_rules = assign(:inbox_cleaner_rules, FactoryGirl.create_list(:inbox_cleaner_rule, SpecMisc::MEDIUM_LIST_SIZE))
    render
    inbox_cleaner_rules_rendered = JSON.parse(rendered)

    expected_attributes = %w(uid from_address to_address subject list_id)

    inbox_cleaner_rules.zip(inbox_cleaner_rules_rendered).each do |inbox_cleaner_rule, inbox_cleaner_rule_rendered|
      spec_validate_attributes(expected_attributes, inbox_cleaner_rule, inbox_cleaner_rule_rendered)
    end
  end
end
