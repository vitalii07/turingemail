# == Schema Information
#
# Table name: yahoo_mail_accounts
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  email                  :text
#  verified_email         :boolean
#  sync_started_time      :datetime
#  last_history_id_synced :text
#  created_at             :datetime
#  updated_at             :datetime
#  sync_delayed_job_id    :integer
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :yahoo_mail_account do
    user

    sequence(:email) { |n| "email#{n}@hotmail.com" }
    verified_email true

    last_history_id_synced nil
  end
end
