FactoryGirl.define do
  factory :google_contact do
    before(:create) do |gc|
      if gc.email_account.nil?
        gc.email_account = FactoryGirl.create :gmail_account
      end
    end
    contact_title 'John Snow'
    contact_email 'j.snow@westeros.com'
  end
end
