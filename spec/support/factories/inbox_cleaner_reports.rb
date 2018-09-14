# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inbox_cleaner_report do
    read_emails 0
    list_emails 0
    calendar_emails 0
    auto_respond_emails 0
    progress 0
    email_account nil
  end
end
