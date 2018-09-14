require 'rails_helper'

RSpec.describe ApiSessionsHelper, :type => :helper do
  describe "#add_user_auth_keys_to_current_user" do
    let!(:user) { FactoryGirl.create(:user) }

    it 'returns the user' do
      expect( helper.add_user_auth_keys_to_current_user(user) ).to eq(user)
    end
  end #__End of describe "#add_user_auth_keys_to_current_user"__

  describe "#signed_in_to_api?" do
    let!(:user) { FactoryGirl.create(:user) }

    context "when the user is already signed in" do
      before do
        helper.add_user_auth_keys_to_current_user(user)
      end

      it 'returns the true' do
        expect( helper.signed_in_to_api? ).to eq(true)
      end
    end #__End of context "when the user is already signed in"__

    context "when the user is not already signed in" do
      it 'returns the false' do
        expect( helper.signed_in_to_api? ).to eq(false)
      end
    end
  end #__End of describe "#signed_in_to_api?"__

  describe "#current_user_with_user_auth_keys=" do
    let!(:user) { FactoryGirl.create(:user) }

    it 'assigns the current_user_with_user_auth_keys instance variable to the user' do
      helper.current_user_with_user_auth_keys = user

      expect( helper.instance_variable_get(:@current_user_with_user_auth_keys) ).to eq(user)
    end
  end #__End of describe "#current_user_with_user_auth_keys="__

  describe "#current_user_with_user_auth_keys" do
    let!(:user) { FactoryGirl.create(:user) }

    context "when the auth_key cookies is nil" do
      it 'returns nil' do
        expect( helper.current_user_with_user_auth_keys ).to eq(nil)
      end
    end #__End of context "when the auth_key cookies is nil"__

    context "when the auth_key cookies is not nil" do
      before do
        helper.cookies[:auth_key] = "auth key"
      end

      context "when the current_user_with_user_auth_keys instance variable exists" do
        before do
          helper.current_user_with_user_auth_keys = user
        end

        it 'returns the current user' do
          expect( helper.current_user_with_user_auth_keys ).to eq(user)
        end
      end #__End of context "when the current_user_with_user_auth_keys instance variable exists"__

      context "when the current_user_with_user_auth_keys instance variable does not exist" do
        it 'encrypts the auth key' do
          expect(UserAuthKey).to receive(:secure_hash).with("auth key")
          helper.current_user_with_user_auth_keys
        end

        it 'finds the cached user auth key with the encrypted auth key' do
          allow(UserAuthKey).to receive(:secure_hash).and_return("user-auth-key")
          expect(UserAuthKey).to receive(:cached_find_by_encrypted_auth_key).with("user-auth-key")
          helper.current_user_with_user_auth_keys
        end

        context "when finds the cached user auth key with the encrypted auth key" do
          let!(:user_auth_key) { UserAuthKey.new }
          before do
            allow(UserAuthKey).to receive(:cached_find_by_encrypted_auth_key).and_return(user_auth_key)
          end

          it 'finds the cached user' do
            expect(User).to receive(:cached_find)
            helper.current_user_with_user_auth_keys
          end

          it 'returns the cached user' do
            allow(User).to receive(:cached_find).and_return(user)
            expect( helper.current_user_with_user_auth_keys ).to eq(user)
          end
        end #__End of context "when finds the cached user auth key with the encrypted auth key"__

        context "when does not find the cached user auth key with the encrypted auth key" do
          before do
            allow(UserAuthKey).to receive(:cached_find_by_encrypted_auth_key).and_return(nil)
          end

          it 'returns nil' do
            expect( helper.current_user_with_user_auth_keys ).to eq(nil)
          end
        end #__End of context "when does not find the cached user auth key with the encrypted auth key"__
      end #__End of context "when the current_user_with_user_auth_keys instance variable does not exist"__
    end #__End of context "when the auth_key cookies is not nil"__
  end #__End of describe "#current_user_with_user_auth_keys"__

  describe "#current_user_with_user_auth_keys?" do
    let!(:user) { FactoryGirl.create(:user) }
    let!(:another_user) { FactoryGirl.create(:user) }

    context "when the user is equal to the current user" do
      before do
        helper.add_user_auth_keys_to_current_user(user)
      end

      it 'returns true' do
        expect( helper.current_user_with_user_auth_keys?(user) ).to eq(true)
      end
    end #__End of context "when the user is equal to the current user"__

    context "when the user is not equal to the current user" do
      before do
        helper.add_user_auth_keys_to_current_user(another_user)
      end

      it 'returns false' do
        expect( helper.current_user_with_user_auth_keys?(user) ).to eq(false)
      end
    end #__End of context "when the user is not equal to the current user"__
  end #__End of describe "#current_user_with_user_auth_keys?"__

  describe "#render_authentication_message" do

    #TODO Maybe we can make this more specific (redirect_to routes)
    context "for the api" do
      it 'redirects to users show' do
        helper.should_receive("redirect_to")
        helper.render_authentication_message(true)
      end
    end #__End of context "for the api"__

    context "for no api" do
      it 'should respond with a redirect page' do
        helper.should_receive("redirect_to")
        helper.render_authentication_message
      end
    end #__End of context "for no api"__
  end #__End of describe "#render_authentication_message"__

  describe "#set_email_account" do
    context "when the user is NOT sign in" do
      it 'raises the error' do
        expect{ helper.set_email_account }.to raise_error
      end
    end #__End of context "when the user is NOT sign in"__

    context "when the user is sign in" do
      context "when the user does not have any gmail account" do
        let!(:user) { FactoryGirl.create(:user) }
        before do
          helper.add_user_auth_keys_to_current_user(user)
        end

        it 'renders the email accoutn not found json error' do
          allow(helper).to receive(:current_email_account).and_return(nil)
          helper.should_receive("render").with(:status => $config.http_errors[:email_account_not_found][:status_code], :json => $config.http_errors[:email_account_not_found][:description])
          helper.set_email_account
        end
      end #__End of context "when the user does not have any gmail account"__

      context "when the user has any gmail account" do
        let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
        before do
          helper.add_user_auth_keys_to_current_user(gmail_account.user)
        end

        it 'assigns the email_account instance variable to the first gmail account' do
          allow(helper).to receive(:current_email_account).and_return(gmail_account)
          helper.set_email_account
          expect( helper.instance_variable_get(:@email_account) ).to eq(gmail_account)
        end
      end #__End of context "when the user has any gmail account"__
    end #__End of context "when the user is sign in"__
  end #__End of describe "#set_email_account"__

  describe "#sign_out_from_api" do
    let!(:user) { FactoryGirl.create(:user) }

    context "when the auth_key cookie exists" do
      before do
        helper.add_user_auth_keys_to_current_user(user)
      end

      context "when finds the user auth key by the auth_key cookie" do
        let!(:user_auth_key) { UserAuthKey.new }
        before do
          allow(UserAuthKey).to receive(:find_by).and_return(user_auth_key)
        end

        xit 'destroys the user auth key' do
          expect_any_instance_of(UserAuthKey).to receive(:destroy)
          helper.sign_out_from_api
        end
      end #__End of context "when finds the user auth key by the auth_key cookie"__
    end #__End of context "when the auth_key cookie exists"__

    it 'deletes the auth_key cookie' do
      helper.sign_out_from_api
      expect( helper.cookies[:auth_key] ).to eq(nil)
    end

    it 'sets the current user to nil' do
      helper.sign_out_from_api
      expect( helper.current_user_with_user_auth_keys ).to eq(nil)
    end
  end #__End of describe "#sign_out_from_api"__

  describe "#redirect_back_or" do
    context "when the return_to session exists" do
      before do
        helper.session[:return_to] = "return_to"
      end

      it 'redirects to the return_to url' do
        helper.should_receive("redirect_to").with("return_to")
        helper.redirect_back_or("default")
      end

      it 'deletes the return_to session' do
        helper.should_receive("redirect_to")
        helper.redirect_back_or("default")
        expect( helper.session[:return_to] ).to eq(nil)
      end
    end #__End of context "when the return_to session exists"__

    context "when the return_to session does not exists" do
      it 'redirects to the default url' do
        helper.should_receive("redirect_to").with("default")
        helper.redirect_back_or("default")
      end
    end #__End of context "when the return_to session does not exist"__
  end #__End of describe "#redirect_back_or"__

  describe "#store_location" do
    context "for the get request" do
      it 'sets the return_to session to the request url' do
        helper.store_location
        expect( helper.session[:return_to] ).to eq(helper.request.url)
      end
    end #__End of context "for the get request"__
  end #__End of describe "#store_location"__
end
