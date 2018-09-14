require "rails_helper"
require 'csv'

describe "subscription", type: :feature, js: true do

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

    SubscriptionPlan.create!(amount: 499900, interval: "month", stripe_id: "1", name: "Individual Monthly Plan")

    capybara_signin_user(User.first)

  end

  context "in subscriptions/new page" do

    before do
      visit '/subscriptions/new'
    end

    it "should redirect to Monthly Subscription page" do
      expect(page).to have_text("Monthly Subscription")
    end

    it "should have New Subscription Form" do
      expect(page).to have_selector("form.payola-onestep-subscription-form")
    end

    it "should have 'email' input" do
      expect(page).to have_selector('form.payola-onestep-subscription-form input[data-payola="email"]')
    end

    it "should have current user\'s email in email input" do
      expect(find('form.payola-onestep-subscription-form input[data-payola="email"]').value).to eq(User.first.email)
    end

    it "should have 'Card Number' input" do
      expect(page).to have_selector('form.payola-onestep-subscription-form input[data-stripe="number"]')
    end

    it "should have 'Exp Month' input" do
      expect(page).to have_selector('form.payola-onestep-subscription-form input[data-stripe="exp_month"]')
    end

    it "should have 'Exp Year' input" do
      expect(page).to have_selector('form.payola-onestep-subscription-form input[data-stripe="exp_year"]')
    end

    it "should have 'CVC' input" do
      expect(page).to have_selector('form.payola-onestep-subscription-form input[data-stripe="cvc"]')
    end

    it "should have submit button" do
      expect(page).to have_selector('form.payola-onestep-subscription-form input[type="submit"]')
    end

    context "when input valid value" do

      before do
        find('form.payola-onestep-subscription-form input[data-stripe="number"]').set('4242424242424242')
        find('form.payola-onestep-subscription-form input[data-stripe="exp_month"]').set('12')
        find('form.payola-onestep-subscription-form input[data-stripe="exp_year"]').set(Time.now.year + 1)
        find('form.payola-onestep-subscription-form input[data-stripe="cvc"]').set('123')
        find('form.payola-onestep-subscription-form input[type="submit"]').click
      end

      it "should redirect to main page" do

      end

    end

  end

end