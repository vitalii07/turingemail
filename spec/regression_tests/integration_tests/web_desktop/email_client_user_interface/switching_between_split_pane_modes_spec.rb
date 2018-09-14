require "rails_helper"

describe "switching between split pane modes", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:email_account) { FactoryGirl.create(:gmail_account, user: user) }
  let(:inbox) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => email_account) }
  let(:email_threads_inbox) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account) }
  let(:email_recipient) { FactoryGirl.create(:email_recipient) }

  before do
    create_email_thread_emails(email_threads_inbox, email_folder: inbox)
    allow(EmailFolder).to receive(:get_sorted_paginated_threads).and_return(email_threads_inbox)
    allow_any_instance_of(GmailAccount).to receive(:emails_set_seen)

    capybara_signin_user(user)
  end

  context "by default" do

    it "is in vertical split pane mode" do
      expect(page).to have_selector(".vertical-split-pane")
    end

    it "is not in horizontal split pane mode" do
      expect(page).to_not have_selector(".horizontal-split-pane")
    end

    it "is not in no split pane mode" do
      expect(page).to_not have_selector(".no-split-pane")
    end

  end

  context "when the horizontal split pane button is clicked" do
    before { find(".tm_button-stack.split-mode-btn-group button:nth-child(1)").click }

    it "is in horizontal split pane mode" do
      expect(page).to have_selector(".horizontal-split-pane")
    end

    it "is not in vertical split pane mode" do
      expect(page).to_not have_selector(".vertical-split-pane")
    end

    it "is not in no split pane mode" do
      expect(page).to_not have_selector(".no-split-pane")
    end

  end

  context "when the no split pane button is clicked" do
    before { find(".tm_button-stack.split-mode-btn-group button:nth-child(3)").click }

    it "is in no split pane mode" do
      expect(page).to have_selector(".no-split-pane")
    end

    it "is not in horizontal split pane mode" do
      expect(page).to_not have_selector(".horizontal-split-pane")
    end

    it "is not in vertical split pane mode" do
      expect(page).to_not have_selector(".vertical-split-pane")
    end

  end

end