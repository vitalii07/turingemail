require "rails_helper"
require 'csv'

describe "moving emails to email folders", type: :feature, js: true do
  let!(:gmail_data) {
    {"id"=>"Label_id", "name"=>"My folder", "messageListVisibility"=>"show", "labelListVisibility"=>"labelShow"}
  }

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

    allow_any_instance_of(Google::GmailClient).to receive(:labels_create).and_return(gmail_data)

    capybara_signin_user(User.first)
  end

  it "finds the Move To Folder button" do
    expect(page).to have_selector("button.tm_button.move-to-folder-dropdown-menu")
  end

  context "when no select checkbox" do
    it 'moves the current opened email thread to the new folder' do
      moved_email_subject = find(".read.currently-being-read .mail-subject").text

      # click the Move To Folder button
      find("button.tm_button.move-to-folder-dropdown-menu").click

      # click Create New link in the dropdown
      within(".move-to ul.dropdown-menu") do
        find("a.createNewEmailFolder").click
      end

      # type the folder name
      find(".create-folder-modal .create-folder-input").set(gmail_data["name"])

      # click Create button
      within(".create-folder-form") do
        find("button.tm_button-blue").click
      end

      # click the new folder
      find("a#Label_id").click

      expect( find(".read.currently-being-read .mail-subject") ).to have_content( moved_email_subject )
      expect( find('.tm_mail-thread-header .tm_mail-thread-subject').find('h2') ).to have_content( moved_email_subject )

    end
  end

  context "when select any checkbox" do
    before do
      find(".threads-toolbar .tm_button.tm_button-caret").click

      within(".threads-toolbar") do
        find("a.all-bulk-action").click
      end
    end

    it 'moves the selected email threads to the new folder' do
      # click the Move To Folder button
      find("button.tm_button.move-to-folder-dropdown-menu").click

      # click Create New link in the dropdown
      within(".move-to ul.dropdown-menu") do
        find("a.createNewEmailFolder").click
      end

      # type the folder name
      find(".create-folder-modal .create-folder-input").set(gmail_data["name"])

      # click Create button
      within(".create-folder-form") do
        find("button.tm_button-blue").click
      end

      # click the new folder
      find("a#Label_id").click

      expect(page).to have_selector("table.tm_table-mail")

      # click the inbox link
      find("a.tm_folder-inbox").click

      expect(page).not_to have_selector("table.tm_table-mail")
    end
  end
end