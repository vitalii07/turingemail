require 'rails_helper'

RSpec.describe Api::V1::EmailAccountsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe ".send_email" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_accounts/send_email'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }
      let!(:params) {
        {
            :tos => nil,
            :ccs => nil,
            :bccs => nil,
            :subject => nil,
            :html_part => nil,
            :text_part => nil,
            :email_in_reply_to_uid => nil,
            :tracking_enabled => true,
            :reminder_enabled => true,
            :reminder_time => nil,
            :reminder_type => nil,
            :attachment_s3_keys => nil
        }
      }
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
      before do
        @emails = Email.all
        # allow_any_instance_of(GmailAccount).to receive(:delay).and_return( @emails )
        allow(EmailSenderJob).to receive(:perform_async).with(gmail_account.id, nil, params.values) # we use organized array
        # allow(@emails).to receive(:send_email)
      end

      it 'responds with a 200 status code' do
        post '/api/v1/email_accounts/send_email', params
        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        post '/api/v1/email_accounts/send_email', params
        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end

      it 'sends email on the background' do
        Sidekiq::Testing.inline! do
          post '/api/v1/email_accounts/send_email', params
          expect(EmailSenderJob).to have_received(:perform_async).with(gmail_account.id, nil, params.values) # we use organized array
        end
        # expect(@emails).to have_received(:send_email).with( params[:tos], params[:ccs], params[:bccs],
        #                                                     params[:subject], params[:html_part], params[:text_part],
        #                                                     params[:email_in_reply_to_uid],
        #                                                     params[:tracking_enabled].downcase == 'true',
        #                                                     params[:reminder_enabled].downcase == 'true', params[:reminder_time], params[:reminder_type],
        #                                                     params[:attachment_s3_keys])
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".send_email"__

  describe ".send_email_delayed" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_accounts/send_email_delayed'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:params) {
        {
          :tos => "tos",
          :ccs => "ccs",
          :bccs => "bccs",
          :subject => "subject",
          :html_part => "html part",
          :text_part => "text part",
          :email_in_reply_to_uid => "reply-to-uid",
          :tracking_enabled => true,
          :reminder_enabled => 'True',
          :reminder_time => "2015-03-06 07:26:05.607070004 +0100",
          :reminder_type => "reminder type",
          :attachment_s3_keys => 's3-keys',
          :sendAtDateTime => 3.days.from_now
        }
      }

      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        post '/api/v1/email_accounts/send_email_delayed', params
        expect(response.status).to eq(200)
      end

      it 'renders the api/v1/delayed_emails/show rabl' do
        expect( post '/api/v1/email_accounts/send_email_delayed', params ).to render_template('api/v1/delayed_emails/show')
      end

      it 'creates new DelayedEmail with the params' do
        delayed_email = DelayedEmail.new
        allow(DelayedEmail).to receive(:new) { delayed_email }


        post '/api/v1/email_accounts/send_email_delayed', params

        expect( delayed_email.email_account ).to eq(gmail_account)
        expect( delayed_email.tos ).to eq(params[:tos])
        expect( delayed_email.ccs ).to eq(params[:ccs])
        expect( delayed_email.bccs ).to eq(params[:bccs])
        expect( delayed_email.subject ).to eq(params[:subject])
        expect( delayed_email.html_part ).to eq(params[:html_part])
        expect( delayed_email.text_part ).to eq(params[:text_part])
        expect( delayed_email.email_in_reply_to_uid ).to eq(params[:email_in_reply_to_uid])
        expect( delayed_email.tracking_enabled ).to eq(params[:tracking_enabled])
        expect( delayed_email.reminder_enabled ).to be(true)
        expect( delayed_email.reminder_time ).to eq(params[:reminder_time])
        expect( delayed_email.reminder_type ).to eq(params[:reminder_type])
        expect( delayed_email.attachment_s3_keys ).to eq(params[:attachment_s3_keys])

      end

      context "with the draft_id" do
        before do
          params[:draft_id] = "draft-id"
        end

        it 'deletes the draft' do
          expect_any_instance_of(GmailAccount).to receive(:delete_draft)

          post '/api/v1/email_accounts/send_email_delayed', params
        end
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".send_email_delayed"__

  describe ".sync" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_accounts/sync'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account, last_sync_at: 5.minutes.ago) }
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }
      # simulate for EmailAccountsController#sync_email  because in test env it does not create real jobs
      before { allow_any_instance_of(String).to receive(:job_id).and_return('value') }
      before { allow(SyncAccountJob).to receive(:perform_later).and_return('value') }

      it 'queues the background job' do
        post '/api/v1/email_accounts/sync'
        expect(SyncAccountJob).to have_received(:perform_later).with(gmail_account.id).once
      end

      ## TODO turn it on if need to use .already_in_sync? method.
      # it 'should not queue in sync email' do
      #   gmail_account.set_job_uid!('value')
      #   post '/api/v1/email_accounts/sync'
      #   expect(SyncAccountJob).not_to have_received(:perform_later).with(gmail_account.id)
      # end

      it 'returns the last sync time' do
        post '/api/v1/email_accounts/sync'

        expect(response.status).to eq(200)
        expect(response.body).to eq(gmail_account.last_sync_at.to_json)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".sync"__

  describe ".search_threads" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_accounts/search_threads'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([[], 1])
        post '/api/v1/email_accounts/search_threads'
        expect(response.status).to eq(200)
      end

      it 'renders the search_threads rabl' do
        allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([[], 1])
        expect( post '/api/v1/email_accounts/search_threads' ).to render_template(:search_threads)
      end

      it 'has "next_page_token", "email_threads" keys' do
        allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([[], 1])
        post '/api/v1/email_accounts/search_threads'
        search_threads = JSON.parse(response.body)

        expect( search_threads.keys.include?("next_page_token") ).to be(true)
        expect( search_threads.keys.include?("email_threads") ).to be(true)
      end

      context 'no email threads' do
        before do
          allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([[], 1])
        end

        it 'returns the empty array' do
          post '/api/v1/email_accounts/search_threads'
          email_threads = JSON.parse(response.body)["email_threads"]
          expect( email_threads ).to eq( [] )
        end
      end

      context "with email threads" do
        let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
        let!(:email_thread) { FactoryGirl.create(:email_thread, :email_account => gmail_account) }
        let!(:email) { FactoryGirl.create_list(:email, 2, email_thread: email_thread)}
        let!(:next_page_token) { 2 }
        let!(:email_thread_uids) { EmailThread.pluck(:uid) }

        before do
          allow_any_instance_of(GmailAccount).to receive(:search_threads).and_return([email_thread_uids, next_page_token])

          post '/api/v1/email_accounts/search_threads'
        end

        it 'returns the email threads' do
          email_threads_stats = JSON.parse(response.body)["email_threads"]

          email_threads_stats.each do |email_thread_rendered|
            validate_email_thread(email_thread, email_thread_rendered)
          end
          # expect( email_threads.count ).to eq()
        end
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".search_threads"__

  describe ".create_draft" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_accounts/drafts'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email) }
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:create_draft).and_return(email)
        post '/api/v1/email_accounts/drafts'
        expect(response.status).to eq(200)
      end

      it 'renders the api/v1/emails/show rabl' do
        allow_any_instance_of(GmailAccount).to receive(:create_draft).and_return(email)
        expect( post '/api/v1/email_accounts/drafts' ).to render_template('api/v1/emails/show')
      end

      it 'creates new draft email' do
        expect_any_instance_of(GmailAccount).to receive(:create_draft).and_return(email)

        post '/api/v1/email_accounts/drafts'
      end

      it 'returns the email' do
        allow_any_instance_of(GmailAccount).to receive(:create_draft).and_return(email)
        post '/api/v1/email_accounts/drafts'

        email_rendered = JSON.parse(response.body)
        validate_email(email, email_rendered)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".create_draft"__

  describe ".update_draft" do
    context 'when the user is NOT signed in' do
      before do
        put '/api/v1/email_accounts/drafts'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email) }
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:update_draft).and_return(email)
        put '/api/v1/email_accounts/drafts'
        expect(response.status).to eq(200)
      end

      it 'renders the api/v1/emails/show rabl' do
        allow_any_instance_of(GmailAccount).to receive(:update_draft).and_return(email)
        expect( put '/api/v1/email_accounts/drafts' ).to render_template('api/v1/emails/show')
      end

      it 'updates the draft email' do
        expect_any_instance_of(GmailAccount).to receive(:update_draft).and_return(email)

        put '/api/v1/email_accounts/drafts'
      end

      it 'returns the email' do
        allow_any_instance_of(GmailAccount).to receive(:update_draft).and_return(email)
        put '/api/v1/email_accounts/drafts'

        email_rendered = JSON.parse(response.body)
        validate_email(email, email_rendered)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".update_draft"__

  describe ".send_draft" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_accounts/send_draft'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email) }
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:send_draft).and_return(email)
        post '/api/v1/email_accounts/send_draft'
        expect(response.status).to eq(200)
      end

      it 'sends the draft' do
        expect_any_instance_of(GmailAccount).to receive(:send_draft).and_return(email)

        post '/api/v1/email_accounts/send_draft'
      end

      it 'returns the empty hash' do
        allow_any_instance_of(GmailAccount).to receive(:send_draft).and_return(email)
        post '/api/v1/email_accounts/send_draft'

        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".send_draft"__

  describe ".delete_draft" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_accounts/delete_draft'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'responds with a 200 status code' do
        allow_any_instance_of(GmailAccount).to receive(:delete_draft)
        post '/api/v1/email_accounts/delete_draft'
        expect(response.status).to eq(200)
      end

      it 'deletes the draft' do
        expect_any_instance_of(GmailAccount).to receive(:delete_draft)

        post '/api/v1/email_accounts/delete_draft'
      end

      it 'returns the empty hash' do
        allow_any_instance_of(GmailAccount).to receive(:delete_draft)
        post '/api/v1/email_accounts/delete_draft'

        result = JSON.parse(response.body)

        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".delete_draft"__

  describe ".cleaner_overview" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/email_accounts/cleaner_overview'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email, seen: true, email_account: gmail_account) }
      let!(:inbox_cleaner_report) { FactoryGirl.create(:inbox_cleaner_report, email_account: gmail_account) }
      let!(:inbox_label) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }

      before do
        post '/api/v1/api_sessions',
             email: gmail_account.user.email,
             password: gmail_account.user.password
      end

      it 'renders the number of emails' do
        num_emails = gmail_account.inbox_folder.andand.emails.size() || 0

        get '/api/v1/email_accounts/cleaner_overview'

        result = JSON.parse(response.body)

        expect( result["num_emails"] ).to eq(num_emails)
      end

      it 'renders the report date' do
        report_date = gmail_account.inbox_cleaner_report.andand.created_at.strftime("%B %e, %Y")

        get '/api/v1/email_accounts/cleaner_overview'

        result = JSON.parse(response.body)

        expect( result["report_date"] ).to eq(report_date)
      end

      it 'responds with a 200 status code' do
        get '/api/v1/email_accounts/cleaner_overview'

        expect(response.status).to eq(200)
      end

      it 'renders the cleaner_report rabl' do
        expect( get '/api/v1/email_accounts/cleaner_overview' ).to render_template(:cleaner_overview)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".cleaner_overview"__

  describe ".create_cleaner_report" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_accounts/cleaner_report'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email, seen: true, email_account: gmail_account) }
      let!(:inbox_cleaner_report) { FactoryGirl.create(:inbox_cleaner_report, email_account: gmail_account) }

      before do
        post '/api/v1/api_sessions',
             email: gmail_account.user.email,
             password: gmail_account.user.password
      end

      it 'destroys the inbox cleaner report' do
        expect_any_instance_of(InboxCleanerReport).to receive(:destroy).at_least(:once)

        post '/api/v1/email_accounts/cleaner_report'
      end

      it 'creates the inbox cleaner report' do
        expect_any_instance_of(GmailAccount).to receive(:create_inbox_cleaner_report).and_call_original

        post '/api/v1/email_accounts/cleaner_report'
      end

      it 'runs the inbox cleaner report' do
        expect_any_instance_of(InboxCleanerReport).to receive(:delay).and_call_original

        post '/api/v1/email_accounts/cleaner_report'
      end

      it 'responds with a 200 status code' do
        post '/api/v1/email_accounts/cleaner_report'

        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        post '/api/v1/email_accounts/cleaner_report'

        result = JSON.parse(response.body)

        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".create_cleaner_report"__

  describe ".destroy_cleaner_report" do
    context 'when the user is NOT signed in' do
      before do
        delete '/api/v1/email_accounts/cleaner_report'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email, seen: true, email_account: gmail_account) }
      let!(:inbox_cleaner_report) { FactoryGirl.create(:inbox_cleaner_report, email_account: gmail_account) }

      before do
        post '/api/v1/api_sessions',
             email: gmail_account.user.email,
             password: gmail_account.user.password
      end

      it 'destroys the inbox cleaner report' do
        expect_any_instance_of(InboxCleanerReport).to receive(:destroy).at_least(:once)

        delete '/api/v1/email_accounts/cleaner_report'
      end

      it 'responds with a 200 status code' do
        delete '/api/v1/email_accounts/cleaner_report'

        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        delete '/api/v1/email_accounts/cleaner_report'

        result = JSON.parse(response.body)

        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".destroy_cleaner_report"__

  describe ".cleaner_report" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/email_accounts/cleaner_report'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email, seen: true, email_account: gmail_account) }
      let!(:inbox_cleaner_report) { FactoryGirl.create(:inbox_cleaner_report, email_account: gmail_account) }

      before do
        post '/api/v1/api_sessions',
             email: gmail_account.user.email,
             password: gmail_account.user.password
      end

      it 'responds with a 200 status code' do
        get '/api/v1/email_accounts/cleaner_report'
        expect(response.status).to eq(200)
      end

      it 'renders the cleaner_report rabl' do
        expect( get '/api/v1/email_accounts/cleaner_report' ).to render_template(:cleaner_report)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".cleaner_report"__

  describe ".apply_cleaner" do
    context 'when the user is NOT signed in' do
      before do
        put '/api/v1/email_accounts/cleaner_report'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
      let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }
      let!(:inbox_label) { FactoryGirl.create(:gmail_label_inbox, :gmail_account => gmail_account) }
      let!(:emails) { Email.all }

      before do
        post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password
        allow_any_instance_of(GmailLabel).to receive(:emails).and_return(emails)
      end

      context "for the read category" do
        let!(:category) { "read" }
        let!(:folder_name) { "Archived" }

        it 'gets all the read emails' do
          expect(emails).to receive(:inbox_cleaner_read).and_return(emails)

          put '/api/v1/email_accounts/cleaner_report', category: category
        end

        it 'updates all the read emails' do
          allow(emails).to receive(:inbox_cleaner_read).and_return(emails)
          expect(emails).to receive(:update_all).with(auto_file_folder_name: folder_name)

          put '/api/v1/email_accounts/cleaner_report', category: category
        end
      end #__End of context "for the read category"__

      context "for the calendar category" do
        let!(:category) { "calendar" }
        let!(:folder_name) { "Archived/Calendar" }

        it 'gets all the calendar emails' do
          expect(emails).to receive(:inbox_cleaner_calendar).and_return(emails)

          put '/api/v1/email_accounts/cleaner_report', category: category
        end

        it 'updates all the read emails' do
          allow(emails).to receive(:inbox_cleaner_calendar).and_return(emails)
          expect(emails).to receive(:update_all).with(auto_file_folder_name: folder_name)

          put '/api/v1/email_accounts/cleaner_report', category: category
        end
      end #__End of context "for the calendar category"__

      context "for the auto respond category" do
        let!(:category) { "auto_respond" }
        let!(:folder_name) { "Archived/Auto-Respond" }

        it 'gets all the auto respond emails' do
          expect(emails).to receive(:inbox_cleaner_auto_respond).and_return(emails)

          put '/api/v1/email_accounts/cleaner_report', category: category
        end

        it 'updates all the auto respond emails' do
          allow(emails).to receive(:inbox_cleaner_auto_respond).and_return(emails)
          expect(emails).to receive(:update_all).with(auto_file_folder_name: folder_name)

          put '/api/v1/email_accounts/cleaner_report', category: category
        end
      end #__End of context "for the auto respond category"__

      context "for the list category" do
        let!(:category) { "list" }
        let!(:folder_name) { "Archived/List" }

        it 'gets all the list emails' do
          expect(emails).to receive(:inbox_cleaner_list).and_return(emails)

          put '/api/v1/email_accounts/cleaner_report', category: category
        end

        it 'updates all the list emails' do
          allow(emails).to receive(:inbox_cleaner_list).and_return(emails)
          expect(emails).to receive(:update_all).with(auto_file_folder_name: folder_name)

          put '/api/v1/email_accounts/cleaner_report', category: category
        end
      end #__End of context "for the list category"__

      context "for the before category" do
        let!(:category) { "before" }
        let!(:folder_name) { "Archived" }
        let!(:before_date) { Time.now }

        it 'gets all the before emails' do
          expect(emails).to receive(:where).with( "date < ?", DateTime.parse(before_date.to_s) ).and_return(emails)

          put '/api/v1/email_accounts/cleaner_report', category: category, before_date: before_date
        end

        it 'updates all the before emails' do
          allow(emails).to receive(:where).and_return(emails)
          expect(emails).to receive(:update_all).with(auto_file_folder_name: folder_name)

          put '/api/v1/email_accounts/cleaner_report', category: category, before_date: before_date
        end
      end #__End of context "for the before category"__

      context "for the from category" do
        let!(:category) { "from" }
        let!(:folder_name) { "Archived" }
        let!(:from_address) { "from-address" }

        it 'gets all the from address emails' do
          expect(emails).to receive(:where).with( from_address: from_address ).and_return(emails)

          put '/api/v1/email_accounts/cleaner_report', category: category, from_address: from_address
        end

        it 'updates all the from address emails' do
          allow(emails).to receive(:where).and_return(emails)
          expect(emails).to receive(:update_all).with(auto_file_folder_name: folder_name)

          put '/api/v1/email_accounts/cleaner_report', category: category, from_address: from_address
        end
      end #__End of context "for the from category"__

      it 'applys the cleaner' do
        expect_any_instance_of(GmailAccount).to receive(:delay).and_call_original

        put '/api/v1/email_accounts/cleaner_report', category: "read"
      end

      it 'responds with a 200 status code' do
        put '/api/v1/email_accounts/cleaner_report', category: "read"

        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        put '/api/v1/email_accounts/cleaner_report', category: "read"

        apply_cleaner_stats = JSON.parse(response.body)
        expect(apply_cleaner_stats).to eq({})
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".apply_cleaner"__
end
