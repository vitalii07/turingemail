# == Schema Information
#
# Table name: delayed_emails
#
#  id                    :integer          not null, primary key
#  email_account_id      :integer
#  email_account_type    :string(255)
#  delayed_job_id        :integer
#  uid                   :text
#  tos                   :text
#  ccs                   :text
#  bccs                  :text
#  subject               :text
#  html_part             :text
#  text_part             :text
#  email_in_reply_to_uid :text
#  tracking_enabled      :boolean
#  reminder_enabled           :boolean          default(FALSE)
#  reminder_time      :datetime
#  reminder_type      :text
#  created_at            :datetime
#  updated_at            :datetime
#  attachment_s3_keys    :text
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :delayed_email do
    before(:create) do |email|
      if email.email_account.nil?
        email.email_account = FactoryGirl.create(:gmail_account)
      end
    end
    sequence(:subject) { |n| "Test Subject #{n}" }

    html_part '<html>Test email text</html>'
    text_part 'Test email text'
    tos ['foo@example.com']
    bccs []
    ccs []
  end
end
