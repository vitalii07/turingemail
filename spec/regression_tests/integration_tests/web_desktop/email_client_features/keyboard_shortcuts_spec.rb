require "rails_helper"
require 'csv'

describe "keyboard shortcuts spec", type: :feature, js: true do
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

  it "should show compose modal when press 'C'" do
    find("body").native.send_keys('c')
    expect(page).to have_selector(".compose-modal.in")
  end

  it "should select and show the next email when press 'down' arrow" do
    find("body").native.send_keys(:arrow_down)
    expect(page.all(".tm_table-mail tr.read")[1][:class].include?("currently-being-read")).to eq(true)
  end

  it "should select and show the prev email when press 'up' arrow" do
    find("body").native.send_keys(:arrow_down)
    find("body").native.send_keys(:arrow_up)
    expect(page.all(".tm_table-mail tr.read")[0][:class].include?("currently-being-read")).to eq(true)
  end

  it "should select and show the next email when press 'j'" do
    find("body").native.send_keys('j')
    expect(page.all(".tm_table-mail tr.read")[1][:class].include?("currently-being-read")).to eq(true)
  end

  it "should select and show the original email when press 'k'" do
    find("body").native.send_keys('j')
    find("body").native.send_keys('k')
    expect(page.all(".tm_table-mail tr.read")[0][:class].include?("currently-being-read")).to eq(true)
  end

  it "should be archived when press 'e'" do
    original_count = page.all(".tm_table-mail tr.read").count
    find("body").native.send_keys('j')
    find("body").native.send_keys('e')
    expect(page.all(".tm_table-mail tr.read").count).to eq(original_count-1)
  end

  it "should be archived when press 'y'" do
    original_count = page.all(".tm_table-mail tr.read").count
    find("body").native.send_keys('j')
    find("body").native.send_keys('y')
    expect(page.all(".tm_table-mail tr.read").count).to eq(original_count-1)
  end

  context "when press 'r'" do

    before do
      find("body").native.send_keys('j')
      find("body").native.send_keys('r')
    end

    it "should have compose modal" do
      expect(page).to have_selector(".compose-modal.in")
    end

    it "should have compose modal in reply mode" do
      expect(page.find(".tm_input.subject-input").value.include?("Re:")).to eq(true)
    end

  end

  context "when press 'f'" do

    before do
      find("body").native.send_keys('j')
      find("body").native.send_keys('f')
    end

    it "should have compose modal" do
      expect(page).to have_selector(".compose-modal.in")
    end

    it "should have compose modal in forward mode" do
      expect(page.find(".tm_input.subject-input").value.include?("Fwd:")).to eq(true)
    end

  end

  context "when press 'v'" do

    before do
      find("body").native.send_keys('j')
      find("body").native.send_keys('v')
    end

    it "should have 'Move to Folder' notification" do
      expect(page).to have_text("Move to Folder")
    end

    it "should have move-to-folder dropdown" do
      expect(page).to have_selector(".dropdown.move-to.open")
    end

  end

end