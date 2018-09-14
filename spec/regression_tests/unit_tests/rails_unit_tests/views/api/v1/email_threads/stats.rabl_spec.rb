require 'rails_helper'

RSpec.describe 'api/v1/email_threads/stats', :type => :view do
  it 'should render the email thread stats' do
    email_thread = assign(:email_thread, FactoryGirl.create(:email_thread))
    FactoryGirl.create_list(:email, SpecMisc::LARGE_LIST_SIZE, :email_thread => email_thread)

    render

    email_thread_stats_rendered = JSON.parse(rendered)
    validate_email_thread_stats(email_thread_stats_rendered)
  end
end
