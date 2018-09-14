# Read about factories at https://github.com/thoughtbot/factory_girl

FactoryGirl.define do
  factory :inbox_cleaner_datum, :class => 'InboxCleanerData' do
    is_read false
    is_calendar false
    is_list false
    is_auto_respond false
  end
end
