require 'rails_helper'

RSpec.describe Api::V1::UsersController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end

  describe ".update" do
    context 'when the user is NOT signed in' do
      before do
        patch '/api/v1/users/update'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:profile_picture) { "profile picture" }
      let!(:name) { "user name" }

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'updates the profile_picture field with the params' do
        params = { :profile_picture => profile_picture }

        expect_any_instance_of(User).to receive(:update_attributes!).with(params.with_indifferent_access).and_call_original

        patch '/api/v1/users/update', params
      end

      it 'updates the name field with the params' do
        params = { :name => name }

        expect_any_instance_of(User).to receive(:update_attributes!).with(params.with_indifferent_access).and_call_original

        patch '/api/v1/users/update', params
      end

      it 'renders the "api/v1/users/show" rabl' do
        expect( patch '/api/v1/users/update' ).to render_template('api/v1/users/show')
      end

      it 'responds with a 200 status code' do
        patch '/api/v1/users/update'

        expect(response.status).to eq(200)
      end

      context "when the exception raises" do
        before do
          allow_any_instance_of(User).to receive(:update_attributes!) {
            raise Exception
          }
          patch '/api/v1/users/update'
        end

        it 'responds with the user_update_error status code' do
          expect(response.status).to eq($config.http_errors[:user_update_error][:status_code])
        end

        it 'returns the user_update_error message' do
          expect(response.body).to eq($config.http_errors[:user_update_error][:description])
        end
      end #__End of context "when the exception raises"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".update"__

  describe ".current" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/users/current'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'renders the "api/v1/users/show" rabl' do
        expect( get '/api/v1/users/current' ).to render_template('api/v1/users/show')
      end

      it 'responds with a 200 status code' do
        get '/api/v1/users/current'

        expect(response.status).to eq(200)
      end

      it 'renders the current user' do
        get '/api/v1/users/current'

        result = JSON.parse(response.body)
        expect(result["email"]).to eq(user.email)
      end

      it 'renders dashboard' do
        get '/api/v1/users/dashboard'
        result = JSON.parse(response.body)
        expect(result['membership']['from_date']).not_to be blank?
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".current"__

  describe ".installed_apps" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/users/installed_apps'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:installed_app) { FactoryGirl.create(:installed_app, user: user) }
      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'renders the "api/v1/installed_apps/index" rabl' do
        expect( get '/api/v1/users/installed_apps' ).to render_template('api/v1/installed_apps/index')
      end

      it 'responds with a 200 status code' do
        get '/api/v1/users/installed_apps'

        expect(response.status).to eq(200)
      end

      it 'renders the installed apps' do
        expect_any_instance_of(User).to receive(:installed_apps).and_call_original

        get '/api/v1/users/installed_apps'
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".installed_apps"__

  describe ".declare_email_bankruptcy" do
    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/users/declare_email_bankruptcy'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      let!(:gmail_account) { FactoryGirl.create(:gmail_account, user: user) }
      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      context "when the inbox label exists" do
        before do
          allow_any_instance_of(GmailAccount).to receive(:inbox_folder) { true }
        end

        it 'destroys all the email folder mappings' do
          expect_any_instance_of(EmailFolderMapping::ActiveRecord_Relation).to receive(:destroy_all)

          post '/api/v1/users/declare_email_bankruptcy'
        end
      end #__End of context "when the inbox label exists"__


      it 'should response with a 200 status' do

        post '/api/v1/users/declare_email_bankruptcy'

        expect(response.status).to eq(200)
      end

      it 'renders the empty hash' do
        post '/api/v1/users/declare_email_bankruptcy'

        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".declare_email_bankruptcy"__

  describe ".upload_attachment_post" do
    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/users/upload_attachment_post'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do
      let!(:user) { FactoryGirl.create(:user) }
      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'creates new EmailAttachmentUpload' do
        expect(EmailAttachmentUpload).to receive(:new).and_call_original

        get '/api/v1/users/upload_attachment_post'
      end

      it 'saves the user field of the EmailAttachmentUpload to the current user' do
        get '/api/v1/users/upload_attachment_post'

        expect(user.reload.email_attachment_uploads.count).not_to eq(0)
      end

      it 'should respond with a 200 status' do
        get '/api/v1/users/upload_attachment_post'

        expect(response.status).to eq(200)
      end

      it 'presigns the post' do
        expect_any_instance_of(EmailAttachmentUpload).to receive(:presigned_post).and_call_original

        get '/api/v1/users/upload_attachment_post'
      end

      it 'renders the presigned post url' do
        email_attachment_upload = EmailAttachmentUpload.new
        email_attachment_upload.user = user
        email_attachment_upload.save!
        presigned_post = email_attachment_upload.presigned_post()

        allow_any_instance_of(EmailAttachmentUpload).to receive(:presigned_post) { presigned_post }

        get '/api/v1/users/upload_attachment_post'

        result = JSON.parse(response.body)

        expect(result["url"]).to eq(presigned_post.url.to_s)
      end

      it 'renders the presigned post fields' do
        email_attachment_upload = EmailAttachmentUpload.new
        email_attachment_upload.user = user
        email_attachment_upload.save!
        presigned_post = email_attachment_upload.presigned_post()

        allow_any_instance_of(EmailAttachmentUpload).to receive(:presigned_post) { presigned_post }

        get '/api/v1/users/upload_attachment_post'

        result = JSON.parse(response.body)

        expect(result["fields"]).to eq(presigned_post.fields)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".upload_attachment_post"__
end
