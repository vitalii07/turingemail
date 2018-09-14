require "rails_helper"

describe "archiving emails", type: :feature, js: true do
  let(:email_account) { FactoryGirl.create(:gmail_account) }
  let(:inbox) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => email_account) }
  let(:email_threads_inbox) { FactoryGirl.create_list(:email_thread, SpecMisc::TINY_LIST_SIZE, :email_account => email_account) }

  before do
    create_email_thread_emails(email_threads_inbox, email_folder: inbox)
    allow(EmailFolder).to receive(:get_sorted_paginated_threads).and_return(email_threads_inbox)
    allow_any_instance_of(GmailAccount).to receive(:emails_set_seen)

    capybara_signin_user(email_account.user)
  end

  context "in the inbox" do
    it "finds the Archive button" do
      expect(page).to have_selector("button.tm_button.archive-button")
    end

    it "opens the latest email" do
      latest_email = email_threads_inbox.first.latest_email

      expect( find(".read.currently-being-read .mail-subject") ).to have_content( latest_email.subject )
      expect( find('.tm_mail-thread-header .tm_mail-thread-subject').find('h2') ).to have_content( latest_email.subject )
    end

    context "when no select checkbox" do
      context "when click the Archive button" do
        before do
          find("button.tm_button.archive-button").click
        end

        it "archives the current opened email thread" do
          archived_email = email_threads_inbox.first.latest_email

          expect( find(".read.currently-being-read .mail-subject") ).not_to have_content( archived_email.subject )
          expect( find('.tm_mail-thread-header .tm_mail-thread-subject').find('h2') ).not_to have_content( archived_email.subject )
        end
      end
    end

    context "when select any checkbox" do
      before do
        find(".threads-toolbar .tm_button.tm_button-caret").click

        within(".threads-toolbar") do
          find("a.all-bulk-action").click
        end
      end

      context "when click the Archive button" do
        before do
          find("button.tm_button.archive-button").click
        end

        it "archives the selected email thread" do
          expect(page).not_to have_selector('table.tm_table-mail tr')
        end
      end
    end
  end
end