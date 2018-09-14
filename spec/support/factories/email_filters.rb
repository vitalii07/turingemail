# == Schema Information
#
# Table name: email_filters
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  uid                     :text
#  from_address            :text
#  to_address              :text
#  subject                 :text
#  list_id                 :text
#  destination_folder_name :text
#  created_at              :datetime
#  updated_at              :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_filter do
    email_account_type "EmailAccount"
    words { FFaker::Lorem.words }
    email_addresses { [FFaker::Internet.email] }
  end
end
