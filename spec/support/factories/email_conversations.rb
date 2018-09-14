# == Schema Information
#
# Table name: people
#
#  id                 :integer          not null, primary key
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#  emails_count       :integer
#  email_account_id   :integer
#  email_account_type :string(255)
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :email_conversation do
    association :email_account, :factory => :gmail_account
  end
end
