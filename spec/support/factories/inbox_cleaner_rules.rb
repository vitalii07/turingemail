# == Schema Information
#
# Table name: inbox_cleaner_rules
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uid          :text
#  from_address :text
#  to_address   :text
#  subject      :text
#  list_id      :text
#  created_at   :datetime
#  updated_at   :datetime
#

# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inbox_cleaner_rule do
    user

    sequence(:uid) { |n| n.to_s }
    sequence(:list_id) { |n| "sales_#{n}.turinginc.com" }
  end
end
