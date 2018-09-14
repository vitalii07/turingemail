require 'rails_helper'

RSpec.describe GmailAccountsHelper, :type => :helper do
  describe '#outlook_o_auth2_url' do
    let!(:o_auth2_base_client) { Outlook::OAuth2Client.base_client($config.outlook_client_id, $config.outlook_secret) }
    let!(:options) {
      {
        :access_type => :offline,
        :include_granted_scopes => true
      }
    }

    before do
      o_auth2_base_client.redirect_uri = $config.outlook_oauth2_callback_url
      o_auth2_base_client.scope = OutlookAccount::SCOPES
    end

    context "for the force" do
      before do
        options[:approval_prompt] = :force
      end

      it 'returns the forced outlook omni auth2 url' do
        url = o_auth2_base_client.authorization_uri(options).to_s()

        expect(helper.outlook_o_auth2_url(true)).to eq(url)
      end
    end

    context "for no force" do
      before do
        options[:approval_prompt] = :auto
      end

      it 'returns the not forced outlook omni auth2 url' do
        url = o_auth2_base_client.authorization_uri(options).to_s()
        
        expect(helper.outlook_o_auth2_url).to eq(url)
      end
    end
  end
end
