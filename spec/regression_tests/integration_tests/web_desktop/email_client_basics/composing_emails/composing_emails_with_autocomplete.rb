require "rails_helper"
require 'csv'

describe "composing emails with autocomplete", type: :feature, js: true do

###################
##### Stories #####
###################
#
# 1. Set up the test with an address populated in the People model.
# 2. Sign in.
# 3. Click the compose button.
# 4. Click to field.
# 5. Type in a prefix of the address that was populated in the people model.
# 6. Verify that the autocomplete dropdown shows the address.
# 7. Click the address on the autocomplete dropdown.
# 8. Verify that the to field contains the address.

    let(:email_folder_mappings) { File.read('spec/support/data/test_data/email_folder_mappings.csv') }
    let(:email_folder_mappings_1) { File.read('spec/support/data/test_data/email_folder_mappings_1.csv') }
    let(:emails) { File.read('spec/support/data/test_data/emails.csv') }
    let(:email_threads) { File.read('spec/support/data/test_data/email_threads.csv') }
    let(:gmail_accounts) { File.read('spec/support/data/test_data/gmail_accounts.csv') }
    let(:gmail_labels) { File.read('spec/support/data/test_data/gmail_labels.csv') }
    let(:first_gmail_label) { File.read('spec/support/data/test_data/first_gmail_label.csv') }
    let(:google_o_auth2_tokens) { File.read('spec/support/data/test_data/google_o_auth2_tokens.csv') }
    let(:people) {File.read('spec/support/data/test_data/people.csv')}
    let(:users) { File.read('spec/support/data/test_data/users.csv') }

    before do
      users_csv = CSV.parse(users, :headers => true)
      users_csv.each do |row|
        User.create!(row.to_hash)
      end

      gmail_accounts_csv = CSV.parse(gmail_accounts, :headers => true)
      gmail_accounts_csv.each do |row|
        GmailAccount.create!(row.to_hash)
      end

      google_o_auth2_tokens_csv = CSV.parse(google_o_auth2_tokens, :headers => true)
      google_o_auth2_tokens_csv.each do |row|
        GoogleOAuth2Token.create!(row.to_hash)
      end

      email_threads_csv = CSV.parse(email_threads, :headers => true)
      email_threads_csv.each do |row|
        EmailThread.create!(row.to_hash)
      end

      gmail_labels_csv = CSV.parse(first_gmail_label, :headers => true)
      gmail_labels_csv.each do |row|
        GmailLabel.create!(row.to_hash)
      end

      emails_csv = CSV.parse(emails, :headers => true)
      emails_csv.each do |row|
        Email.create!(row.to_hash)
      end

      email_folder_mappings_csv = CSV.parse(email_folder_mappings_1, :headers => true)
      email_folder_mappings_csv.each do |row|
        EmailFolderMapping.create!(row.to_hash)
      end

      people_csv = CSV.parse(people, :headers => true)
      people_csv.each do |row|
        Person.create!(row.to_hash)
      end
      capybara_signin_user(User.first)
  	end

  	context "when click compose button" do

  	  before do
    	 click_button("Compose")
  	  end

  	  it "should have autocomplete 'to' input" do
        expect(page).to have_selector(".tm_input.to-input.ui-autocomplete-input")
  	  end

  	  context "when input 'a'" do

  	  	before do
  	  		sleep(10)
  	  		find(".tm_compose-field .to-input").set("a")
  	  	end

  	  	it "should have autocomplete list" do
  	  		expect(page).to have_selector("#ui-id-1")
  	  	end

  	  	context "when select 'abc@test.com'" do

  	  		before do
  	  			sleep(10)
  	  			first("#ui-id-1 li").click
  	  		end

  	  		it "should have 'abc@test.com' in to input" do
  	  			expect(find(".tm_compose-field .to-input").value).to eq("abc@test.com")
  	  		end

  	  	end

  	  end

  	end

end