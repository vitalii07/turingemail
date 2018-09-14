# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :subscription_plan do
    amount 1
    interval "MyString"
    stripe_id "1"
    name "MyString"
  end
end
