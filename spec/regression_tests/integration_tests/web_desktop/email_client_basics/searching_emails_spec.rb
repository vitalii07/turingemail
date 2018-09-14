require "rails_helper"
require 'csv'

describe "searching emails", type: :feature, js: true do
  let(:email_folder_mappings) { File.read('spec/support/data/test_data/email_folder_mappings.csv') }
  let(:email_folder_mappings_1) { File.read('spec/support/data/test_data/email_folder_mappings_1.csv') }
  let(:emails) { File.read('spec/support/data/test_data/emails.csv') }
  let(:email_threads) { File.read('spec/support/data/test_data/email_threads.csv') }
  let(:gmail_accounts) { File.read('spec/support/data/test_data/gmail_accounts.csv') }
  let(:gmail_labels) { File.read('spec/support/data/test_data/gmail_labels.csv') }
  let(:first_gmail_label) { File.read('spec/support/data/test_data/first_gmail_label.csv') }
  let(:google_o_auth2_tokens) { File.read('spec/support/data/test_data/google_o_auth2_tokens.csv') }
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

    capybara_signin_user(User.first)

  end

  it "should have search box" do
    expect(page).to have_selector(".tm_search-field input")
  end

  context "when input wrong search query with 'wrongsearchquery'" do

    before do
      find(".tm_search-field input").set("wrongsearchquery")
    end

    it "should have no results panel when press 'enter'" do
      find(".tm_search-field input").native.send_keys(:return)
      expect(page).to have_content("Your search had no results.")
      expect(page).to have_content("0 Emails Found")
    end

    it "should have empty panel also when click search button" do
      find(".tm_search-field-buttons button[type='submit']").click
      expect(page).to have_content("Your search had no results.")
      expect(page).to have_content("0 Emails Found")
    end

  end

  context "when input search query with 'gmail'" do

    before do
      find(".tm_search-field input").set("gmail")
    end

    context "when press 'enter'" do

      before do
        find(".tm_search-field input").native.send_keys(:return)
      end

      it "should have results box" do
        expect(page).to have_selector(".tm_table-mail")
      end

      it "should have 2 results" do
        expect(page.all(".tm_table-mail tr").count).to eq(2)
      end

    end

    context "when click search button" do

      before do
        find(".tm_search-field-buttons button[type='submit']").click
      end

      it "should have results box" do
        expect(page).to have_selector(".tm_table-mail")
      end

      it "should have 2 results" do
        expect(page.all(".tm_table-mail tr").count).to eq(2)
      end

    end

  end

end