###################
##### Stories #####
###################
#
# 1. Sign in.
# 2. Go to the inbox.
# 3. Check the checkboxes for a couple of emails.
# 4. Click the snooze dropdown.
# 5. Click the 1 hour link.
# 6. Verify that the selected emails are no longer in the inbox.
# 7. If there is a way to simulate time being sped up, check that the emails return to the inbox after an hour.

require "rails_helper"
require 'csv'

describe "email snooze spec", type: :feature, js: true do
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

  context "in the inbox page" do
    it "finds the Snooze button" do
      expect(page).to have_selector("button.tm_button.snooze-dropdown-menu")
    end

    context "when select any checkbox" do
      let!(:email_thread_uid) { "14cfe737d79b1765" }
      let!(:email_ids) { [2, 6] }

      before do
        visit("/mail#email_thread/#{email_thread_uid}")
      end

      xit 'snoozes the current opened email thread from the inbox' do
        snoozed_email_subject = find(".read.currently-being-read .tm_table-mail-subject .mail-subject").text

        $config.gmail_live = false

        # click the Snooze button
        find("button.tm_button.snooze-dropdown-menu").click

        # click Create New link in the dropdown
        within(".snooze-dropdown ul.dropdown-menu") do
          find("a.one-hour").click
        end

        expect( find(".read.currently-being-read .tm_table-mail-subject .mail-subject") ).not_to have_content( snoozed_email_subject )

        sleep 120

        gmail_account = GmailAccount.first
        gmail_account.wake_up(email_ids)

        sleep 120

        expect( find("table.tm_table-mail .tm_table-mail-body .read:nth-child(2) .tm_table-mail-subject .mail-subject") ).to have_content( snoozed_email_subject )
      end
    end

  end
end