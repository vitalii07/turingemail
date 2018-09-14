require "rails_helper"

describe "switching between multiple accounts", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:email_account1) { FactoryGirl.create(:gmail_account, user: user) }
  let(:email_account2) { FactoryGirl.create(:gmail_account, user: user) }
  let(:inbox1) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => email_account1) }
  let(:inbox2) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => email_account2) }
  let(:email_threads_inbox1) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account1) }
  let(:email_threads_inbox2) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account2) }
  let(:email_recipient) { FactoryGirl.create(:email_recipient) }

  before do
    create_email_thread_emails(email_threads_inbox1, email_folder: inbox1)
    create_email_thread_emails(email_threads_inbox2, email_folder: inbox2)
    allow(EmailFolder).to receive(:get_sorted_paginated_threads).and_return(email_threads_inbox1)
    allow_any_instance_of(GmailAccount).to receive(:emails_set_seen)

    capybara_signin_user(user)
  end

  context "by default" do
    it 'synchronizes with the last email account' do
      expect( find(".tm_user-info small") ).to have_content( email_account2.email )
    end
  end

  context "by switching the another email account" do
    before do
      sleep 5
      find(".tm_user-info").click
      find(".email-account-link").click
      sleep 5
    end

    it 'synchronizes with the switched email account' do
      expect( find(".tm_user-info small") ).to have_content( email_account1.email )
    end
  end

end