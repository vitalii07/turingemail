FactoryGirl.define do
  factory :twitter_account do
    user

    access_token "factory"
    access_token_secret "factory"
  end
end
