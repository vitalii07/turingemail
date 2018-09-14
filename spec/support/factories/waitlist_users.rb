# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :waitlist_user do
    sequence(:email) { |n| "foo#{n}@bar.com" }
    collection_type 'csr'
  end

end
