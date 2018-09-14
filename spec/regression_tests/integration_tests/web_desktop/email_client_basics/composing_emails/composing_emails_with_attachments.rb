require "rails_helper"
require 'csv'

describe "composing emails with attachments", type: :feature, js: true do

###################
##### Stories #####
###################
#
# 1. Sign in.
# 2. Click the compose button.
# 3. Click the upload attachment button.
# 4. Select a file from the upload attachment system dropdown.
# 5. Verify that the file is attached compose view.
# 6. Click send.
# 7. Verify that that 'Your message has been sent' text is displayed.

    let(:user) { FactoryGirl.create(:user) }
    let(:email_recipient) { FactoryGirl.create(:email_recipient) }
    let(:file_path){ "/spec/support/data/test_data/test.jpg" }
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

    context "when click compose button" do

      before do
        click_button("Compose")
      end

      it "should have attachment button" do
        expect(page).to have_selector(".tm_upload-attachment.tm_upload-nofile input", visible: false)
      end

      context "when choose file" do
        
        before do
          page.execute_script <<-JS
            fakeFileInput = $("input[type='file']");
            fakeFileInput.attr("id","fake");
          JS
          attach_file("fake", File.join(Rails.root, file_path), visible: false)
          # Trigger the fake drop event
          page.execute_script <<-JS
            var fileList = fakeFileInput.get(0).files;
            var e = jQuery.Event('drop', { dataTransfer : { files : fileList } });
            $('.compose-email-dropzone').trigger(e);
          JS
        end
      
        it "should have attached file" do
          expect(page).to have_selector(".tm_upload-attachment.tm_upload-complete")
        end

        context "when click send with no recipients" do

          before { click_button("Send") }

          it "should show 'Email has no recipients!'" do
            expect(page).to have_text("Email has no recipients!")
          end

        end

        context "when click send with recipients" do

          before do
            find(".tm_compose-field .to-input").set("noreply@turinginc.com")
            click_button("Send")
          end

          it "should show 'Your message has been sent'" do
            expect(page).to have_text("Your message has been sent.")
          end

        end

      end

    end

end