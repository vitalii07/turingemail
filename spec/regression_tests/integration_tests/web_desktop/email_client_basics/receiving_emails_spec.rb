require "rails_helper"
require 'csv'

describe "receiving emails", type: :feature, js: true do
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

  context "when new email is sent to the email account" do
    let!(:gmail_account) { GmailAccount.first }
    let!(:params) {
      {"reminder_type"=>"never", "reminder_time"=>"", "tos"=>[gmail_account.email], "subject"=>"Test self", "html_part"=>"hey, this is test email", "tracking_enabled"=>"false", "reminder_enabled"=>"false", "text_part"=>"hey, this is test email"}
    }
    let!(:email_raw_sent) { send_email(gmail_account, params) }

    before do
      # skip sync_draft_ids and sync_draft_messages of gmail_account
      allow_any_instance_of(GmailAccount).to receive(:sync_draft_ids)
      allow_any_instance_of(GmailAccount).to receive(:sync_draft_messages)

      # sync the gmail account
      gmail_account.sync_account
    end

    xit 'receives the email' do
      # gets the email by the message id of the email sent
      email = gmail_account.emails.find_by_message_id(email_raw_sent.message_id)

      expect(email).not_to eq(nil)
    end

    xit 'verifies that the sent email is in the inbox' do
      email = gmail_account.emails.find_by_message_id(email_raw_sent.message_id)
      email_thread_uid = email.email_thread.uid
      sent_date = email.date.to_time.strftime("%l:%M %p").strip

      visit ("/mail#email_thread/#{email_thread_uid}")

      expect( find('.email-thread .tm_email .tm_email-info .tm_email-date ') ).to have_content( sent_date )
    end
  end

  def send_email(gmail_account, params)
    # get the raw email from the params
    email_raw, email_in_reply_to = Email.email_raw_from_params(params["tos"], params["ccs"], params["bccs"], params["subject"], params["html_part"], params["text_part"], gmail_account, params["email_in_reply_to_uid"], params["attachment_s3_keys"])

    # refresh the access token of the gmail account
    gmail_account.google_o_auth2_token.refresh()

    # set the from-address with the email of the gmail account
    email_raw.From = gmail_account.email

    # set up smtp
    email_raw.delivery_method.settings = {
        :enable_starttls_auto => true,
        :address              => 'smtp.gmail.com',
        :port                 => 587,
        :domain               => $config.smtp_helo_domain,
        :user_name            => gmail_account.email,
        :password             => gmail_account.google_o_auth2_token.access_token,
        :authentication       => :xoauth2,
        :enable_starttls      => true
    }

    # sends the email
    email_raw.deliver!

    return email_raw
  end
end