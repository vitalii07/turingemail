# == Schema Information
#
# Table name: yahoo_mail_o_auth2_tokens
#
#  id              :integer          not null, primary key
#  api_id   :integer
#  api_type :string(255)
#  access_token    :text
#  expires_in      :integer
#  issued_at       :integer
#  refresh_token   :text
#  expires_at      :datetime
#  created_at      :datetime
#  updated_at      :datetime
#

require 'rails_helper'

RSpec.describe YahooMailOAuth2Token, :type => :model do
  let(:yahoo_mail_account) { FactoryGirl.create(:yahoo_mail_account) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:api_id).of_type(:integer)  }
      it { should have_db_column(:api_type).of_type(:string)  }
      it { should have_db_column(:access_token).of_type(:text)  }
      it { should have_db_column(:expires_in).of_type(:integer)  }
      it { should have_db_column(:issued_at).of_type(:integer)  }
      it { should have_db_column(:refresh_token).of_type(:text)  }
      it { should have_db_column(:expires_at).of_type(:datetime)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
      it { should have_db_column(:type).of_type(:string)  }
    end

    describe "Indexes" do
      it { should have_db_index([:api_id, :api_type]) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :api }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:api) }
      it { should validate_presence_of(:access_token) }
      it { should validate_presence_of(:expires_in) }
      it { should validate_presence_of(:issued_at) }
      it { should validate_presence_of(:refresh_token) }
      it { should validate_presence_of(:expires_at) }
    end

  end

  #########################
  ### Method Unit Tests ###
  #########################

  describe "Methods" do

    ##################################
    ### Instance Method Unit Tests ###
    ##################################

    describe "Instance methods" do

      #########################################
      ### Getter Instance Method Unit Tests ###
      #########################################

      describe "Getter instance methods" do

        describe ".scopes" do
          let(:yahoo_mail_o_auth2_token) { FactoryGirl.create(:yahoo_mail_o_auth2_token) }

          it "returns the yahoo mail auth2 token's yahoo mail account's scopes" do
            expect(yahoo_mail_o_auth2_token.scopes).to eq(yahoo_mail_o_auth2_token.api.class::SCOPES)
          end

        end #__End of describe ".scopes"__

        describe ".api_client" do
          it "is pending spec implementation"
        end

        describe ".o_auth2_base_client" do
          let(:yahoo_mail_o_auth2_token) { FactoryGirl.create(:yahoo_mail_o_auth2_token) }

          it 'returns the yahoo_mail auth2 base client' do
            expect(yahoo_mail_o_auth2_token.o_auth2_base_client.class).to eq(Signet::OAuth2::Client)
          end

          it 'returns the yahoo_mail auth2 base client with the access_token' do
            expect(yahoo_mail_o_auth2_token.o_auth2_base_client.access_token).to eq(yahoo_mail_o_auth2_token.access_token)
          end

          it 'returns the yahoo_mail auth2 base client with the expires_in' do
            expect(yahoo_mail_o_auth2_token.o_auth2_base_client.expires_in).to eq(yahoo_mail_o_auth2_token.expires_in)
          end

          it 'returns the yahoo_mail auth2 base client with the issued_at' do
            expect(yahoo_mail_o_auth2_token.o_auth2_base_client.issued_at).to eq(Time.at(yahoo_mail_o_auth2_token.issued_at))
          end

          it 'returns the yahoo_mail auth2 base client with the refresh_token' do
            expect(yahoo_mail_o_auth2_token.o_auth2_base_client.refresh_token).to eq(yahoo_mail_o_auth2_token.refresh_token)
          end
        end #__End of describe ".o_auth2_base_client"__

      end

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".refresh" do

          context 'when the expires_at is greater 60 seconds than now and the force is false' do
            it 'does nothing' do
              yahoo_mail_o_auth2_token = FactoryGirl.create(:yahoo_mail_o_auth2_token, expires_at: (DateTime.now + 70.seconds).rfc2822)

              yahoo_mail_o_auth2_token.should_not_receive(:update)
              yahoo_mail_o_auth2_token.refresh(nil, false)
            end
          end

          context 'when the expires_at is smaller 60 seconds than now' do
            before(:all) do
              @yahoo_mail_o_auth2_token = FactoryGirl.create(:yahoo_mail_o_auth2_token, expires_at: (DateTime.now + 10.seconds).rfc2822)

              @o_auth2_base_client = YahooMail::OAuth2Client.base_client($config.yahoo_mail_client_id, $config.yahoo_mail_secret)
              @o_auth2_base_client.access_token = @yahoo_mail_o_auth2_token.access_token
              @o_auth2_base_client.expires_in = @yahoo_mail_o_auth2_token.expires_in
              @o_auth2_base_client.issued_at = Time.at(@yahoo_mail_o_auth2_token.issued_at)
              @o_auth2_base_client.refresh_token = @yahoo_mail_o_auth2_token.refresh_token
            end

            it 'updates itself with the yahoo_mail auth2 base client' do

              allow(@o_auth2_base_client).to receive(:fetch_access_token!) { true }
              allow(@yahoo_mail_o_auth2_token).to receive(:update) { true }

              @yahoo_mail_o_auth2_token.refresh(@o_auth2_base_client)
            end
          end #__End of context 'when the expires_at is smaller 60 seconds than now'__

          context 'when the force is true' do
            before(:all) do
              @yahoo_mail_o_auth2_token = FactoryGirl.create(:yahoo_mail_o_auth2_token)

              @o_auth2_base_client = YahooMail::OAuth2Client.base_client($config.yahoo_mail_client_id, $config.yahoo_mail_secret)
              @o_auth2_base_client.access_token = @yahoo_mail_o_auth2_token.access_token
              @o_auth2_base_client.expires_in = @yahoo_mail_o_auth2_token.expires_in
              @o_auth2_base_client.issued_at = Time.at(@yahoo_mail_o_auth2_token.issued_at)
              @o_auth2_base_client.refresh_token = @yahoo_mail_o_auth2_token.refresh_token
            end

            it 'updates itself with the yahoo_mail auth2 base client' do

              allow(@o_auth2_base_client).to receive(:fetch_access_token!) { true }
              allow(@yahoo_mail_o_auth2_token).to receive(:update) { true }

              @yahoo_mail_o_auth2_token.refresh(@o_auth2_base_client, true)
            end
          end #__End of context 'when the force is true'__
        end #__End of describe ".refresh"__

        describe ".update" do
          let(:yahoo_mail_o_auth2_token1) { FactoryGirl.create(:yahoo_mail_o_auth2_token) }
          let(:yahoo_mail_o_auth2_token2) { FactoryGirl.create(:yahoo_mail_o_auth2_token) }

          context 'when the do_save is true' do
            let(:o_auth2_base_client) { yahoo_mail_o_auth2_token1.o_auth2_base_client }

            before(:each) do
              yahoo_mail_o_auth2_token2.update(o_auth2_base_client, true)
            end

            it 'updates the access_token with the one of the yahoo_mail auth2 base client' do

              expect(yahoo_mail_o_auth2_token2.reload.access_token).to eq(o_auth2_base_client.access_token)
            end

            it 'updates the expires_in with the one of the yahoo_mail auth2 base client' do

              expect(yahoo_mail_o_auth2_token2.reload.expires_in).to eq(o_auth2_base_client.expires_in)
            end

            it 'updates the issued_at with the one of the yahoo_mail auth2 base client' do

              expect(Time.at(yahoo_mail_o_auth2_token2.reload.issued_at)).to eq(o_auth2_base_client.issued_at)
            end

            it 'updates the refresh_token with the one of the yahoo_mail auth2 base client' do

              expect(yahoo_mail_o_auth2_token2.reload.refresh_token).to eq(o_auth2_base_client.refresh_token)
            end

            it 'updates the expires_at with the one of the yahoo_mail auth2 base client' do

              expect(yahoo_mail_o_auth2_token2.reload.expires_at).to eq(o_auth2_base_client.expires_at)
            end
          end
        end #__End of describe ".update"__

        describe ".log" do
          let(:yahoo_mail_o_auth2_token) { FactoryGirl.create(:yahoo_mail_o_auth2_token) }

          it 'calls the log method' do

            allow(yahoo_mail_o_auth2_token).to receive(:log).and_call_original

            yahoo_mail_o_auth2_token.log
          end
        end #__End of describe ".log"__

      end

    end

  end

end
