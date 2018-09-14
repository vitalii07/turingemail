# == Schema Information
#
# Table name: outlook_accounts
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
  factory :outlook_account do
    user

    sequence(:email) { |n| "email#{n}@hotmail.com" }
    verified_email true

    last_history_id_synced nil

    factory :outlook_account_with_imap_folders do

      ignore do
        imap_folders_count 2
      end

      after(:create) do |user, evaluator|
        create_list(:imap_folder, evaluator.imap_folders_count)
      end
    end

  end
end
