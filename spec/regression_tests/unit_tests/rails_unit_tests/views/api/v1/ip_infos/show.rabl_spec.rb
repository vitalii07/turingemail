require 'rails_helper'

RSpec.describe 'api/v1/ip_infos/show', :type => :view do
  it 'should render the user configuration' do
    ip_info = assign(:ip_info, FactoryGirl.create(:ip_info))

    render

    ip_info_rendered = JSON.parse(rendered)

    expected_attributes = %w(automatic_inbox_cleaner_enabled split_pane_mode)
    validate_ip_info(ip_info, ip_info_rendered)
  end
end
