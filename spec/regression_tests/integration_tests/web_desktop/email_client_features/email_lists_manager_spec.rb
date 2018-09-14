require "rails_helper"
require 'csv'

describe "email lists manager spec", type: :feature, js: true do
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

  context "in the Lists page" do
    it 'finds the Lists link in the top bar' do
      expect(page).to have_selector(".tm_toptabs a[href='#list_subscriptions']")
    end

    context "when click the Analytics link" do
      before do
        click_link('Subscriptions')
      end

      it 'finds the Lists title in the tollbar' do
        expect( find('.tm_headbar-page-header') ).to have_content( "Subscriptions" )
      end

      it 'finds the Subscribed Lists link' do
        expect(page).to have_selector(".tm_subscriptions-view a[href='#tab-subscribed']")
      end

      context "when click Subscribed Lists link" do

        it 'shows Subscribed Lists on the page' do
          expect( find('#tab-subscribed .tm_box-heading .expander h2') ).to have_content( "Subscribed Lists" )
        end
      end

      it 'finds the Unsubscribed Lists link' do
        expect(page).to have_selector(".tm_subscriptions-view a[href='#tab-unsubscribed']")
      end

      context "when click Unsubscribed Lists link" do
        before do
          find(".tm_subscriptions-view a[href='#tab-unsubscribed']").click
        end

        it 'shows Unsubscribed Lists on the page' do
          expect( find('#tab-unsubscribed .tm_box-heading .expander h2') ).to have_content( "Unsubscribed Lists" )
        end
      end
    end
  end
end