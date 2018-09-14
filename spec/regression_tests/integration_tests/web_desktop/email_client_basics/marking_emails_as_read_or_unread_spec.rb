require "rails_helper"

describe "marking emails as read or unread", type: :feature, js: true do
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
    context "for the Mark as Read" do
      it "finds the Mark as Read button" do
        expect(page).to have_selector("button.tm_button.mark_as_read")
      end

      context "when no select checkbox" do
        context "when click the Mark as Read button" do
          before do
            find("button.tm_button.mark_as_read").click
          end

          it "marks the current opened email thread as read" do
            read_email = email_threads_inbox.first.latest_email

            expect( find(".read.currently-being-read .mail-subject") ).to have_content( read_email.subject )
            expect( find('.tm_mail-thread-header .tm_mail-thread-subject').find('h2') ).to have_content( read_email.subject )
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

        context "when click the Mark as Read button" do
          before do
            find("button.tm_button.mark_as_read").click
          end

          it "marks the selected email thread as read" do
            expect(page).not_to have_selector('table.tm_table-mail tbody.tm_table-mail-body .unread')
          end
        end
      end
    end

    context "for the Mark as Unread" do
      it "finds the Mark as Unread button" do
        expect(page).to have_selector("button.tm_button.mark_as_unread")
      end

      context "when no select checkbox" do
        context "when click the Mark as Unread button" do
          before do
            find("button.tm_button.mark_as_unread").click
          end

          it "marks the current opened email thread as unread" do
            unread_email = email_threads_inbox.first.latest_email

            expect( find(".unread.currently-being-read .mail-subject") ).to have_content( unread_email.subject )
            expect( find('.tm_mail-thread-header .tm_mail-thread-subject').find('h2') ).to have_content( unread_email.subject )
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

        context "when click the Mark as Unread button" do
          before do
            find("button.tm_button.mark_as_unread").click
          end

          it "marks the selected email thread as unread" do
            expect(page).not_to have_selector('table.tm_table-mail tbody.tm_table-mail-body .read')
          end
        end
      end
    end
  end
end