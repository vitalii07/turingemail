require "rails_helper"
require 'csv'

describe "analytics spec", type: :feature, js: true do
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

  context "in the analytics page" do
    it 'finds the Analytics link in the top bar' do
      expect(page).to have_selector(".tm_toptabs a[href='#analytics']")
    end

    context "when click the Analytics link" do
      before do
        click_link('Analytics')
      end

      it 'finds the Analytics title in the tollbar' do
        expect( find('.tm_headbar-page-header') ).to have_content( "Analytics" )
      end

      it 'finds the Attachments link' do
        expect(page).to have_selector(".tm_analytics-view a[data-target='.attachments_report']")
      end

      context "when click Attachments link" do
        before do
          find(".tm_analytics-view a[data-target='.attachments_report']").click
        end

        it 'shows Attachments Report on the page' do
          expect( find('.attachments_report .tm_box-heading h4') ).to have_content( "Attachments Report" )
        end
      end

      it 'finds the Email Volume link' do
        expect(page).to have_selector(".tm_analytics-view a[data-target='.email_volume_report']")
      end

      context "when click Email Volume link" do
        before do
          find(".tm_analytics-view a[data-target='.email_volume_report']").click
        end

        it 'shows Email Volume Report on the page' do
          expect( find('.email_volume_report .tm_box-heading h4') ).to have_content( "Email Volume Report" )
        end

        it 'shows Daily Email Volume chart' do
          expect(page).to have_selector(".emails-per-day-chart")
        end

        it 'shows Weekly Email Volume chart' do
          expect(page).to have_selector(".emails-per-week-chart")
        end

        it 'shows Monthly Email Volume chart' do
          expect(page).to have_selector(".emails-per-month-chart")
        end
      end

      it 'finds the Folders link' do
        expect(page).to have_selector(".tm_analytics-view a[data-target='.folders_report']")
      end

      context "when click Folders link" do
        before do
          find(".tm_analytics-view a[data-target='.folders_report']").click
        end

        it 'shows Folders Report on the page' do
          expect( find('.folders_report .tm_box-heading h4') ).to have_content( "Folders Report" )
        end

        it 'shows Email Folders chart' do
          expect(page).to have_selector(".email-folders-chart")
        end
      end

      xit 'finds the Geography link' do
        expect(page).to have_selector(".tm_analytics-view a[data-target='.geo_report']")
      end

      context "when click Geography link" do
        before do
          find(".tm_analytics-view a[data-target='.geo_report']").click
        end

        xit 'shows Geography Report on the page' do
          expect( find('.geo_report .tm_box-heading h4') ).to have_content( "Geography Report" )
        end

        xit 'shows Geography chart' do
          expect(page).to have_selector(".geo-chart")
        end
      end

      it 'finds the Lists link' do
        expect(page).to have_selector(".tm_analytics-view a[data-target='.lists_report']")
      end

      context "when click Lists link" do
        before do
          find(".tm_analytics-view a[data-target='.lists_report']").click
        end

        it 'shows Lists Report on the page' do
          expect( find('.lists_report .tm_box-heading h4') ).to have_content( "Lists Report" )
        end

        it 'shows Lists Report table' do
          expect(page).to have_selector(".lists_report table.list-report-statistics")
        end
      end

      it 'finds the Threads link' do
        expect(page).to have_selector(".tm_analytics-view a[data-target='.threads_report']")
      end

      context "when click Threads link" do
        before do
          find(".tm_analytics-view a[data-target='.threads_report']").click
        end

        it 'shows Threads Report on the page' do
          expect( find('.threads_report .tm_box-heading h4') ).to have_content( "Threads Report" )
        end

        it 'shows Threads Report table' do
          expect(page).to have_selector(".threads_report table.list-report-statistics")
        end

        it 'shows top email threads' do
          user = User.first

          top_email_threads = EmailThread.where(:id => user.emails.group(:email_thread_id).order('count_all DESC').limit(10).count.keys).includes(:latest_email).order('emails_count DESC')
          topest_email_thread = top_email_threads.first

          sleep 2

          page.should have_css(".threads_report table.list-report-statistics tr:nth-child(2) a[href='#email_thread/#{topest_email_thread.uid}']")
        end
      end

      it 'finds the Top Contacts link' do
        expect(page).to have_selector(".tm_analytics-view a[data-target='.contacts_report']")
      end

      context "when click Top Contacts link" do
        before do
          find(".tm_analytics-view a[data-target='.contacts_report']").click
        end

        it 'shows Top Contacts Report on the page' do
          expect( find('.contacts_report .tm_box-heading h4') ).to have_content( "Top Contacts Report" )
        end

        it 'shows Contacts Report pie chart of the incoming emails' do
          expect(page).to have_selector(".contacts_report .incoming-emails-container")
        end

        it 'shows Contacts Report pie chart of the outcoming emails' do
          expect(page).to have_selector(".contacts_report .outgoing-emails-container")
        end
      end
    end
  end
end