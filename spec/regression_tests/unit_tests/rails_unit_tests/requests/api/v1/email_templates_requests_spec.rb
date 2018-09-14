require 'rails_helper'

RSpec.describe Api::V1::EmailTemplatesController, :type => :request do
  let!(:user) { FactoryGirl.create(:user) }
  before(:each) do
    login user
  end
  describe '.create' do
    let!(:name) { 'Email template name' }
    let!(:text) { 'lorem ipsum' }
    let!(:html) { '<div>lorem ipsum</div>' }

    context 'when the user is NOT signed in' do
      before do
        post '/api/v1/email_templates', :name => name, :text => text, :html => html
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

      it 'creates new email template' do
        expect(EmailTemplate).to receive(:create!).and_call_original

        post '/api/v1/email_templates', :name => name, :text => text, :html => html
      end

      it 'responds with a 200 status code' do
        post '/api/v1/email_templates', :name => name, :text => text, :html => html

        expect(response.status).to eq(200)
      end

      it 'renders the show rabl' do
        expect( post '/api/v1/email_templates', :name => name, :text => text, :html => html ).to render_template('api/v1/email_templates/show')
      end

      context "when the ActiveRecord::RecordNotUnique raises" do
        before do
          allow(EmailTemplate).to receive(:create!) {
            raise  ActiveRecord::RecordNotUnique.new(1,2)
          }

          post '/api/v1/email_templates', :name => name, :text => text, :html => html
        end

        it 'responds with the email template name in use status code' do
          expect(response.status).to eq($config.http_errors[:email_template_name_in_use][:status_code])
        end

        it 'returns the email template name in use message' do
          expect(response.body).to eq($config.http_errors[:email_template_name_in_use][:description])
        end
      end #__End of context "when the ActiveRecord::RecordNotUnique raises"__
    end #__End of context "when the user is signed in"__
  end #__End of describe ".create"__

  describe '.index' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:email_templates) { FactoryGirl.create_list(:email_template, SpecMisc::MEDIUM_LIST_SIZE, :user => user) }

    context 'when the user is NOT signed in' do
      before do
        get '/api/v1/email_templates'
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'returns the email templates of the current user' do
        expect_any_instance_of(User).to receive(:email_templates).and_call_original

        get '/api/v1/email_templates'
      end

      it 'responds with a 200 status code' do
        get '/api/v1/email_templates'

        expect(response.status).to eq(200)
      end

      it 'renders the index rabl' do
        expect( get '/api/v1/email_templates' ).to render_template(:index)
      end
    end #__End of context "when the user is signed in"__
  end #__End of describe ".index"__

  describe '.update' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_template) { FactoryGirl.create(:email_template, :user => user) }
    let!(:name) { 'Email template name' }
    let!(:text) { 'lorem ipsum' }
    let!(:html) { '<div>lorem ipsum</div>' }

    context 'when the user is NOT signed in' do
      before do
        patch "/api/v1/email_templates/#{email_template.uid}", :name => name, :text => text, :html => html
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'updates the email template' do
        expect_any_instance_of(EmailTemplate).to receive(:update_attributes!)

        patch "/api/v1/email_templates/#{email_template.uid}", :name => name, :text => text, :html => html
      end

      it 'responds with a 200 status code' do
        patch "/api/v1/email_templates/#{email_template.uid}", :name => name, :text => text, :html => html

        expect(response.status).to eq(200)
      end

      it 'renders the show rabl' do
        expect( patch "/api/v1/email_templates/#{email_template.uid}", :name => name, :text => text, :html => html ).to render_template(:show)
      end

      context "when the ActiveRecord::RecordNotUnique raises" do
        before do
          allow_any_instance_of(EmailTemplate).to receive(:update_attributes!) {
            raise  ActiveRecord::RecordNotUnique.new(1,2)
          }

          patch "/api/v1/email_templates/#{email_template.uid}", :name => name, :text => text, :html => html
        end

        it 'responds with the email template name in use status code' do
          expect(response.status).to eq($config.http_errors[:email_template_name_in_use][:status_code])
        end

        it 'returns the email template name in use message' do
          expect(response.body).to eq($config.http_errors[:email_template_name_in_use][:description])
        end
      end #__End of context "when the ActiveRecord::RecordNotUnique raises"__
    end #__End of context "when the user is signed in"__

    context 'when the other user is signed in' do
      before { post '/api/v1/api_sessions', :email => user_other.email, :password => user_other.password }

      before do
        patch "/api/v1/email_templates/#{email_template.uid}", :name => name, :text => text, :html => html
      end

      it 'should respond with the email template not found status code' do
        expect(response.status).to eq($config.http_errors[:email_template_not_found][:status_code])
      end

      it 'should respond with the email template not found message' do
        expect( response.body ).to eq( $config.http_errors[:email_template_not_found][:description] )
      end
    end #__End of context "when the other user is signed in"__
  end #__End of describe ".update"__

  describe '.destroy' do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:user_other) { FactoryGirl.create(:user) }
    let!(:email_template) { FactoryGirl.create(:email_template, :user => user) }

    context 'when the user is NOT signed in' do
      before do
        delete "/api/v1/email_templates/#{email_template.uid}"
      end

      it 'should respond with a 302 status' do
        expect(response.status).to eq(302)
      end

      it 'should respond with a redirect page' do
        expect( response.body ).to eq( "<html><body>You are being <a href=\"http://www.example.com/users/show\">redirected</a>.</body></html>" )
      end
    end #__End of context "when the user is NOT signed in"__

    context 'when the user is signed in' do

      before { post '/api/v1/api_sessions', :email => user.email, :password => user.password }

      it 'destroys the email template category' do
        expect_any_instance_of(EmailTemplate).to receive(:delete)

        delete "/api/v1/email_templates/#{email_template.uid}"
      end

      it 'responds with a 200 status code' do
        delete "/api/v1/email_templates/#{email_template.uid}"

        expect(response.status).to eq(200)
      end

      it 'returns the empty hash' do
        delete "/api/v1/email_templates/#{email_template.uid}"

        result = JSON.parse(response.body)
        expect( result ).to eq( {} )
      end
    end #__End of context "when the user is signed in"__

    context 'when the other user is signed in' do
      before { post '/api/v1/api_sessions', :email => user_other.email, :password => user_other.password }

      before do
        delete "/api/v1/email_templates/#{email_template.uid}"
      end

      it 'should respond with the email template not found status code' do
        expect(response.status).to eq($config.http_errors[:email_template_not_found][:status_code])
      end

      it 'should respond with the email template name in use message' do
        expect( response.body ).to eq( $config.http_errors[:email_template_not_found][:description] )
      end
    end #__End of context "when the other user is signed in"__
  end #__End of describe ".destroy"__
end

