require "rails_helper"
require 'csv'

describe "composing emails with drafts", type: :feature, js: true do

###################
##### Stories #####
###################
#
# 1. Sign in.
# 2. Click the compose button.
# 3. Fill text into the compose body.
# 4. Click the 'Save as draft button'.
# 5. Close the compose modal.
# 6. Click on the drafts label in the sidebar.
# 7. Verify that body of the first opened draft contains the text from above.
# 8. Click send.
# 9. Verify that that 'Your message has been sent' text is displayed.

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
  	# find(".tm_folder-tracked").click
  end

  context "when click" do

  	before { click_button("Compose") }

  	it "should have compose modal" do
  		expect(page).to have_selector(".compose-modal.in")
  	end

  	context "saving as draft" do

  		before do
  			find(".compose-modal.in .redactor-editor").set("draft test")
  			find(".compose-modal.in .tm_button-submit[data-toggle]").click
  			find(".compose-modal.in .save-button").click
  			# wait_for_ajax
  			find(".compose-modal.in [data-dismiss]").click
  			sleep(100)
  		end

  		it "should not have compose modal" do
  			expect(page).to have_no_selector(".compose-modal.in")
  		end

  		it "should have 1 near draft button" do
  			expect(find("#DRAFT .tm_tree-badge")).to have_text("1")
  		end

  		context "when clicked drafts label in the sidebar" do
  			
  			before do
  				find("#DRAFT").click
  			end

  			it "should have the saved draft" do
  				expect(page).to have_selector(".tm_mail-context .redactor-editor")
  				expect(find(".tm_mail-context .redactor-editor")).to have_text("draft test")
  			end

  			context "when click send with no recipients" do

  				before { click_button("Send") }

  				it "should show 'Email has no recipients!'" do
  					expect(page).to have_text("Email has no recipients!")
  				end

  			end

  			context "when click send with recipients" do

  				before do
  					find(".tm_mail-context .to-input").set("noreply@turinginc.com")
  					click_button("Send")
  				end

  				it "should show 'Your message has been sent'" do
  					expect(page).to have_text("Your message has been sent.")
  				end

  			end

  		end

  	end

  end

end