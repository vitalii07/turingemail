require 'rails_helper'

RSpec.describe 'api/v1/email_templates/show', :type => :view do
  let!(:user) { FactoryGirl.create(:user) }

  it 'should render a email_template' do
    email_template = assign(:email_template, FactoryGirl.create(:email_template, :user => user))


    render

    email_template_rendered = JSON.parse(rendered)

    expected_attributes = %w(category_uid
                             uid
                             name
                             text
                             html
                             created_at)

    expected_attributes_to_skip = %w(created_at)
    spec_validate_attributes(expected_attributes, email_template, email_template_rendered, expected_attributes_to_skip)
  end
end
