require "rails_helper"
require 'csv'

describe "email signatures manager spec", type: :feature, js: true do
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

  context "in the Signatures page" do
    let!(:signature_text) { "Hi everyone" }
    let!(:signature_name) { "My signature" }

    it 'finds the Signatures link in the top bar' do
      expect(page).to have_selector(".tm_toptabs a[href='#email_signatures']")
    end

    context "when click the Signatures link" do
      before do
        click_link('Signatures')
      end

      it 'finds the Email Signatures title in the tollbar' do
        expect( find('.tm_headbar-page-header') ).to have_content( "Signatures" )
      end

      it 'finds the Email Signature Compose area' do
        expect(page).to have_selector(".tm_signature-compose")
      end

      it 'finds the Save Signature button' do
        expect(page).to have_selector("button.save-email-signature")
      end

      context "when click Save Signature button" do
        before do
          click_button("Save Signature")
        end

        it "shows the Create Email Signature dialog" do
          expect(page).to have_text("Please fill out the title field!")
        end
      end

      context "when setting a signature title and body, and clicking save signature" do
        before do
          find(".tm_signature-title").set(signature_name)

          find(".tm_signature-compose .redactor-editor").set(signature_text)

          find(".save-email-signature").click
        end

        xit "saves a new email signature" do
          expect(page).to have_text("You have successfully saved an email signature!")
          expect( find('.tm_signature-preview-name') ).to have_content( signature_name )
          expect( find('.tm_signature-preview-html') ).to have_content( signature_text )
        end
      end

      context "after saving a new email signature" do
        before do
          find(".tm_signature-title").set( signature_name )

          click_button("Save Signature")
        end

        context "when choose the radio button of the new emsil signature" do
          it "makes the new signature by the default" do

          end
        end

        context "when click the Edit Signature button" do
          let!(:updated_signature_text) { "This is the signature body"}

          before do
            find(".edit-email-signature").click
            find(".tm_signature-compose .redactor-editor").set( updated_signature_text )
          end

          it "updates the signature" do
            find("button.save-email-signature").click

            expect( find('.tm_signature-preview-html') ).to have_content( updated_signature_text )
          end
        end

        context "when click the Delete Signature button" do

          before do
            click_button("Delete Signature")
          end

          it "shows the confirm dialog" do
            expect(page).to have_selector(".confirmation-modal-dialog")
          end

          context "in the confirm dialog" do
            it "finds the No button" do
              expect(page).to have_selector(".tm_modal-confirmation .no-button")
            end

            it "finds the Yes button" do
              expect(page).to have_selector(".tm_modal-confirmation .yes-button")
            end

            it "closes the confirm dialog on clicking No button" do
              find(".tm_modal-confirmation .no-button").click
              expect(page).to have_no_selector(".confirmation-modal-dialog")
            end

            context "when click the Yes button" do
              before do
                find(".tm_modal-confirmation .yes-button").click
              end

              it "closes the confirm dialog" do
                expect(page).to have_no_selector(".confirmation-modal-dialog")
              end

              it "deletes the signature" do
                expect(page).to have_text("You have successfully deleted an email signature!")
                expect(page).to have_no_selector(".tm_signature-preview")
              end
            end
          end
        end
      end
    end
  end
end