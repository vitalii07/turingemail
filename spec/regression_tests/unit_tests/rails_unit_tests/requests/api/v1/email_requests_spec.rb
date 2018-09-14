require 'rails_helper'

RSpec.describe Api::V1::EmailsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  context 'when the user is NOT signed in' do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }

    it 'should NOT show the email' do
      get "/api/v1/emails/show/#{email.uid}"

      expect(response).to have_http_status(:redirect)
    end
  end

  context 'when the user is signed in' do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }

    before { post '/api/v1/api_sessions', :email => email.user.email, :password => email.user.password }

    it 'should show the email' do
      get "/api/v1/emails/show/#{email.uid}"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/emails/show')

      email_rendered = JSON.parse(response.body)
      expect(email_rendered['uid']).to eq(email.uid)
      expect(email_rendered['uid']).not_to eq(email_other.uid)
    end

    it 'should NOT show the other email' do
      get "/api/v1/emails/show/#{email_other.uid}"

      expect(response).to have_http_status($config.http_errors[:email_not_found][:status_code])
    end
  end

  context 'when the other user is signed in' do
    let!(:email) { FactoryGirl.create(:email) }
    let!(:email_other) { FactoryGirl.create(:email) }

    before { post '/api/v1/api_sessions', :email => email_other.user.email, :password => email_other.user.password }

    it 'should show the other email' do
      get "/api/v1/emails/show/#{email_other.uid}"

      expect(response).to have_http_status(:ok)
      expect(response).to render_template('api/v1/emails/show')

      email_rendered = JSON.parse(response.body)
      expect(email_rendered['uid']).to eq(email_other.uid)
      expect(email_rendered['uid']).not_to eq(email.uid)
    end

    it 'should NOT show the email' do
      get "/api/v1/emails/show/#{email.uid}"

      expect(response).to have_http_status($config.http_errors[:email_not_found][:status_code])
    end
  end

  context 'set_seen' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:emails_not_seen) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account) }
    let!(:emails_seen) { FactoryGirl.create_list(:email, SpecMisc::TINY_LIST_SIZE, :email_account => gmail_account, :seen => "true") }
    let!(:emails_not_seen_uids) { Email.where(:id => emails_not_seen).pluck(:uid) }
    let!(:emails_seen_uids) { Email.where(:id => emails_seen).pluck(:uid) }

    context 'when the user is signed in' do
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should set seen to true' do
        emails_not_seen.each { |email| expect(email.seen).to be(false) }
        post '/api/v1/emails/set_seen', :email_uids => emails_not_seen_uids, :seen => "true"
        Sidekiq::Extensions::DelayedClass.drain
        emails_not_seen.each { |email| expect(email.reload.seen).to be(true) }
      end

      it 'should set seen to false' do
        emails_seen.each { |email| expect(email.seen).to be(true) }
        post '/api/v1/emails/set_seen', :email_uids => emails_seen_uids, :seen => "false"
        Sidekiq::Extensions::DelayedClass.drain
        emails_seen.each { |email| expect(email.reload.seen).to be(false) }
      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/api_sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/emails/set_seen', :email_uids => emails_not_seen_uids, :seen => "false"
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end

      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }

        it 'should NOT set seen to true' do
          expect_any_instance_of(GmailAccount).to receive(:emails_set_seen).with([], true)
          post '/api/v1/emails/set_seen', :email_uids => emails_not_seen_uids, :seen => "true"
          Sidekiq::Extensions::DelayedClass.drain
        end
      end
    end
  end

  context 'move_to_folder' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:gmail_label_other) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
    let!(:email_uids) { Email.where(:id => emails).pluck(:uid) }
    let!(:email_folder_name) { gmail_label_other.name }
    let!(:email_folder_id) { gmail_label_other.id }

    context 'when the user is signed in' do
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should move the emails to the specified folder' do
        email_ids = Email.where(:email_account => gmail_account, :uid => email_uids).pluck(:id)
        query_emails = Email.where(:id => email_ids)

        expect_any_instance_of(GmailAccount).to receive(:move_emails_to_folder).with(query_emails, folder_id: email_folder_id.to_s, folder_name: email_folder_name.to_s)

        post '/api/v1/emails/move_to_folder', :email_uids => email_uids,
                                              :email_folder_name => email_folder_name,
                                              :email_folder_id => email_folder_id

      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/api_sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/emails/move_to_folder', :email_uids => email_uids,
                                                :email_folder_name => gmail_label_other.name
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end

      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }

        it 'should NOT move the emails to the specified folder' do
          expect_any_instance_of(GmailAccount).to receive(:move_emails_to_folder).with([], folder_id: nil,
                                         folder_name: gmail_label_other.name)


          post '/api/v1/emails/move_to_folder', :email_uids => email_uids,
                                                :email_folder_name => gmail_label_other.name
        end
      end
    end
  end

  context 'apply_gmail_label' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:gmail_label_other) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
    let!(:email_uids) { Email.where(:id => emails).pluck(:uid) }
    let!(:gmail_label_id) { gmail_label_other.id }
    let!(:gmail_label_name) { gmail_label_other.name }

    context 'when the user is signed in' do
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should move the emails to the specified folder' do
        email_ids = Email.where(:email_account => gmail_account, :uid => email_uids).pluck(:id)
        query_emails = Email.where(:id => email_ids)

        expect_any_instance_of(GmailAccount).to receive(:apply_label_to_emails).with(query_emails, label_id: gmail_label_id.to_s, label_name: gmail_label_name.to_s)

        post '/api/v1/emails/apply_gmail_label', :email_uids => email_uids,
                                                 :gmail_label_id => gmail_label_id,
                                                 :gmail_label_name => gmail_label_name

      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/api_sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/emails/apply_gmail_label', :email_uids => email_uids,
                                                   :gmail_label_name => gmail_label_other.name
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end

      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }

        it 'should NOT move the emails to the specified folder' do
          expect_any_instance_of(GmailAccount).to receive(:apply_label_to_emails).with([], label_id: nil,
                                         label_name: gmail_label_other.name)

          post '/api/v1/emails/apply_gmail_label', :email_uids => email_uids,
                                                   :gmail_label_name => gmail_label_other.name

        end
      end
    end
  end

  context 'remove_from_folder' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
    let!(:email_uids) { Email.where(:id => emails).pluck(:uid) }
    let!(:email_folder_id) { gmail_label.label_id }

    context 'when the user is signed in' do
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should remove emails from the specified folder' do
        email_ids = Email.where(:email_account => gmail_account, :uid => email_uids).pluck(:id)
        query_emails = Email.where(:id => email_ids)

        expect_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder).with(query_emails, folder_id: email_folder_id)

        post '/api/v1/emails/remove_from_folder', :email_uids => email_uids, :email_folder_id => email_folder_id

      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/api_sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/emails/apply_gmail_label', :email_uids => email_uids, :email_folder_id => gmail_label.label_id
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end

      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }

        it 'should NOT remove emails from the specified folder' do
          expect_any_instance_of(GmailAccount).to receive(:remove_emails_from_folder).with([], folder_id: gmail_label.label_id)

          post '/api/v1/emails/remove_from_folder', :email_uids => email_uids, :email_folder_id => gmail_label.label_id
        end
      end
    end
  end

  context 'trash' do
    let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
    let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }
    let!(:trash_label) { FactoryGirl.create(:gmail_label_trash, :gmail_account => gmail_account) }
    let!(:emails) { FactoryGirl.create_list(:email, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_account) }
    let!(:email_uids) { Email.where(:id => emails).pluck(:uid) }

    context 'when the user is signed in' do
      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'should move emails to trash' do

        email_ids = Email.where(:email_account => gmail_account, :uid => email_uids).pluck(:id)
        query_emails = Email.where(:id => email_ids)

        expect_any_instance_of(GmailAccount).to receive(:trash_emails).with(query_emails)

        post '/api/v1/emails/trash', :email_uids => email_uids

      end
    end

    context 'when the other user is signed in' do
      let!(:user_other) { FactoryGirl.create(:user) }
      before { post '/api/v1/api_sessions', :email => user_other.email, :password => user_other.password }

      context 'when the other user has no email account' do
        it 'should return an error' do
          post '/api/v1/emails/apply_gmail_label', :email_uids => email_uids
          expect(response).to have_http_status($config.http_errors[:email_account_not_found][:status_code])
        end
      end

      context 'when the other user has an email account' do
        let!(:gmail_account_other) { FactoryGirl.create(:gmail_account, :user => user_other) }

        it 'should NOT move emails to trash' do
          expect_any_instance_of(GmailAccount).to receive(:trash_emails).with([])

          post '/api/v1/emails/trash', :email_uids => email_uids
        end
      end
    end
  end
end
