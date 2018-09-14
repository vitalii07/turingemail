require 'rails_helper'

RSpec.describe Api::V1::EmailAttachmentsController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe ".download" do
    let(:email_attachment_path) do
      "/api/v1/email_attachments/download/#{email_attachment.uid}"
    end

    context 'when the user is NOT signed in' do
      let!(:email_attachment) { FactoryGirl.create(:email_attachment) }

      before do
        get email_attachment_path
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

      context "with no email_attachment of the email account" do
        let!(:email_attachment) { FactoryGirl.create(:email_attachment) }

        before { get email_attachment_path }

        it 'responds with the email attachment not found status code' do
          expected = $config.http_errors[:email_attachment_not_found][:status_code]
          expect(response.status).to eq(expected)
        end

        it 'renders the email attachment not found error message' do
          expected = $config.http_errors[:email_attachment_not_found][:description]
          expect(response.body).to eq(expected)
        end
      end #__End of context "with no email_attachment of the email account"__

      context "with email_attachments of the email account" do
        let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }

        context "with carrierwave-uploaded attachment" do
          let!(:email_attachment) { FactoryGirl.create(:email_attachment, :with_file, email: email) }

          before { get email_attachment_path }

          it 'responds with 200 status code' do
            expect(response.status).to eq(200)
          end

          it 'renders the s3 url' do
            expected = email_attachment.file_url

            url = JSON.parse(response.body)["url"]
            expect(url).to eq(expected)
          end
        end

        context "with no attachments_uploaded" do
          let!(:email_attachment) { FactoryGirl.create(:email_attachment, email: email) }

          it 'responds with the email attachment not ready status code' do
            expected = $config.http_errors[:email_attachment_not_ready][:status_code]
            get email_attachment_path
            expect(response.status).to eq(expected)
          end

          it 'renders the email attachment not ready error message' do
            expected = $config.http_errors[:email_attachment_not_ready][:description]
            get email_attachment_path
            expect(response.body).to eq(expected)
          end

          context "when the upload attachment delayed job does not exist" do

            it 'uploads the attachment' do
              expect_any_instance_of(Email).to receive(:delay).and_call_original

              get email_attachment_path
            end

            it 'saves the upload_attachments_delayed_job_id field of the email to the job id' do
              get email_attachment_path

              expect(email.reload.upload_attachments_delayed_job_id).not_to be(nil)
            end
          end #__End of context "when the upload attachment delayed job does not exist"__
        end #__End of context "with no attachments_uploaded of the email_attachment email"__

        context "with attachments_uploaded of the email_attachment email" do
          let!(:email) { FactoryGirl.create(:email, email_account: gmail_account, attachments_uploaded: true) }
          let!(:email_attachment) do
            FactoryGirl.create(:email_attachment, email: email, s3_key: "s3-key")
          end

          it 'responds with 200 status code' do
            get email_attachment_path
            expect(response.status).to eq(200)
          end

          it 'renders the s3 url' do
            expected = s3_url(email_attachment.s3_key)

            get email_attachment_path
            url = JSON.parse(response.body)["url"]

            expect(url).to eq(expected)
          end
        end #__End of context "with no attachments_uploaded of the email_attachment email"__
      end #__End of context "with email_attachments of the email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".download"__

  describe ".index" do
    context 'when the user is NOT signed in' do

      before do
        get "/api/v1/email_attachments"
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
      let!(:email_attachment) { FactoryGirl.create(:email_attachment, email: email) }

      before { post '/api/v1/api_sessions', :email => gmail_account.user.email, :password => gmail_account.user.password }

      it 'orders and filters the email_attachments' do
        expect(EmailAttachment).to receive(:order_and_filter)

        get "/api/v1/email_attachments"
      end

      it 'responds with 200 status code' do
        get "/api/v1/email_attachments"

        expect(response.status).to eq(200)
      end

      it 'renders the api/v1/email_attachments/index rabl' do
        expect(get "/api/v1/email_attachments").to render_template('api/v1/email_attachments/index')
      end

    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__

  describe ".show" do
    context 'when the user is NOT signed in' do
      let!(:email_attachment) { FactoryGirl.create(:email_attachment) }

      before do
        get "/api/v1/email_attachments/#{email_attachment.uid}"
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

      context "with no email_attachment of the email account" do
        let!(:email_attachment) { FactoryGirl.create(:email_attachment) }

        it 'responds with the email attachment not found status code' do
          expected = $config.http_errors[:email_attachment_not_found][:status_code]

          get "/api/v1/email_attachments/#{email_attachment.uid}"
          expect(response.status).to eq(expected)
        end

        it 'renders the email attachment not found error message' do
          expected = $config.http_errors[:email_attachment_not_found][:description]

          get "/api/v1/email_attachments/#{email_attachment.uid}"
          expect(response.body).to eq(expected)
        end
      end #__End of context "with no email_attachment of the email account"__

      context "with the email_attachment of the email account" do
        let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }
        let!(:email_attachment) { FactoryGirl.create(:email_attachment, email: email) }

        it 'responds with 200 status code' do
          get "/api/v1/email_attachments/#{email_attachment.uid}"
          expect(response.status).to eq(200)
        end

        it 'renders the api/v1/email_attachments/show rabl' do
          expect(get "/api/v1/email_attachments/#{email_attachment.uid}").to render_template('api/v1/email_attachments/show')
        end
      end #__End of context "with the email_attachment of the email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".show"__

  describe '.destroy' do
    context 'when the user is NOT signed in' do
      let!(:email_attachment) { FactoryGirl.create(:email_attachment) }

      before do
        delete "/api/v1/email_attachments/#{email_attachment.uid}"
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

      context "with no email_attachment of the email account" do
        let!(:email_attachment) { FactoryGirl.create(:email_attachment) }

        it 'responds with the email attachment not found status code' do
          expected = $config.http_errors[:email_attachment_not_found][:status_code]

          delete "/api/v1/email_attachments/#{email_attachment.uid}"
          expect(response.status).to eq(expected)
        end

        it 'renders the email attachment not found error message' do
          expected = $config.http_errors[:email_attachment_not_found][:description]

          delete "/api/v1/email_attachments/#{email_attachment.uid}"
          expect(response.body).to eq(expected)
        end
      end #__End of context "with no email_attachment of the email account"__

      context "with the email_attachment of the email account" do
        let!(:email) { FactoryGirl.create(:email, email_account: gmail_account) }
        let!(:email_attachment) { FactoryGirl.create(:email_attachment, email: email) }

        it 'destroys the email attachment' do
          expect_any_instance_of(EmailAttachment).to receive(:destroy!)

          delete "/api/v1/email_attachments/#{email_attachment.uid}"
        end

        it 'responds with 200 status code' do
          delete "/api/v1/email_attachments/#{email_attachment.uid}"

          expect(response.status).to eq(200)
        end

        it 'returns the empty hash' do
          delete "/api/v1/email_attachments/#{email_attachment.uid}"

          result = JSON.parse(response.body)
          expect(result).to eq({})
        end
      end #__End of context "with the email_attachment of the email account"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".destroy"__
end
