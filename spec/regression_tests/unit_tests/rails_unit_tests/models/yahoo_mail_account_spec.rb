# == Schema Information
#
# Table name: yahoo_mail_accounts
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  service_id             :text
#  email                  :text
#  verified_email         :boolean
#  sync_started_time      :datetime
#  last_history_id_synced :text
#  created_at             :datetime
#  updated_at             :datetime
#  sync_delayed_job_id    :integer
#

require 'rails_helper'
require 'stringio'

RSpec.describe YahooMailAccount, :type => :model do
  let!(:yahoo_mail_account) { FactoryGirl.create(:yahoo_mail_account) }
  let(:original_data) { "original gmail data" }
  let(:encoded_data) { Base64.urlsafe_encode64(original_data) }
  let(:yahoo_mail_data) { {:raw => encoded_data} }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:user_id).of_type(:integer)  }
      it { should have_db_column(:service_id).of_type(:text)  }
      it { should have_db_column(:service_type).of_type(:text)  }
      it { should have_db_column(:email).of_type(:text)  }
      it { should have_db_column(:verified_email).of_type(:boolean)  }
      it { should have_db_column(:sync_started_time).of_type(:datetime)  }
      it { should have_db_column(:last_history_id_synced).of_type(:text)  }
      it { should have_db_column(:last_sync_at).of_type(:datetime)  }
      it { should have_db_column(:last_sign_in_at).of_type(:datetime)  }
      it { should have_db_column(:sync_delayed_job_uid).of_type(:string)  }
      it { should have_db_column(:auth_errors_counter).of_type(:integer)  }
      it { should have_db_column(:last_suspend_at).of_type(:datetime)  }
      it { should have_db_column(:type).of_type(:string)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
      it { should have_db_column(:last_push_setup_at).of_type(:datetime)  }
      it { should have_db_column(:initial_sync_has_run).of_type(:boolean)  }
    end

    describe "Indexes" do
      it { should have_db_index(:email) }
      it { should have_db_index([:service_id, :service_type]).unique(true) }
      it { should have_db_index(:sync_delayed_job_uid) }
      it { should have_db_index([:user_id, :email]).unique(true) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :user }
    end

    describe "Has one relationships" do
      it { should have_one :yahoo_mail_o_auth2_token }
    end

    describe "Have many relationships" do
      it { should have_many(:email_threads).dependent(:destroy) }
      it { should have_many(:email_conversations).dependent(:destroy) }
      it { should have_many(:emails).dependent(:destroy) }
      it { should have_many(:email_attachments) }
      it { should have_many(:people).dependent(:destroy) }
      it { should have_many(:sync_failed_emails).dependent(:destroy) }
      it { should have_many(:delayed_emails).dependent(:destroy) }
      it { should have_many(:email_trackers).dependent(:destroy) }
      it { should have_many(:email_tracker_recipients) }
      it { should have_many(:email_tracker_views) }
      it { should have_many(:list_subscriptions).dependent(:destroy) }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:user) }
      it { should validate_presence_of(:email) }
      it { should validate_presence_of(:verified_email) }
    end

  end

  ###########################
  ### Constant Unit Tests ###
  ###########################

  describe "Contants" do

    describe "::MESSAGE_BATCH_SIZE" do
      it 'returns 100' do
        expect( YahooMailAccount::MESSAGE_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::DRAFTS_BATCH_SIZE" do
      it 'returns 100' do
        expect( YahooMailAccount::DRAFTS_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::HISTORY_BATCH_SIZE" do
      it 'returns 100' do
        expect( YahooMailAccount::HISTORY_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::SEARCH_RESULTS_PER_PAGE" do
      it 'returns 50' do
        expect( YahooMailAccount::SEARCH_RESULTS_PER_PAGE ).to eq( 50 )
      end
    end

    describe "::NUM_SYNC_DYNOS" do
      it 'returns 3' do
        expect( YahooMailAccount::NUM_SYNC_DYNOS ).to eq( 3 )
      end
    end

    describe "::SCOPES" do
      it 'returns an empty array' do
        expected = []

        expect( YahooMailAccount::SCOPES ).to eq( expected )
      end
    end

    describe "::SMTP_ADDRESS" do
      it 'returns smtp.mail.yahoo.com' do
        expect( YahooMailAccount::SMTP_ADDRESS ).to eq( 'smtp.mail.yahoo.com' )
      end
    end

    describe "::SYSTEM_FOLDERS" do
      it 'returns the system folders' do
        expect( YahooMailAccount::SYSTEM_FOLDERS ).to eq( {"INBOX" => "Inbox",
                                                     "DRAFT" => "Draft",
                                                      "SENT" => "Sent",
                                                     "TRASH" => "Trash"} )
      end
    end

  end

  #########################
  ### Method Unit Tests ###
  #########################

  describe "Methods" do

    ###############################
    ### Class Method Unit Tests ###
    ###############################

    describe "Class methods" do

      ######################################
      ### Getter Class Method Unit Tests ###
      ######################################

      describe "Getter class methods" do

        describe "#get_userinfo" do
          it "is pending spec implementation"
        end

      end

      #################################################
      ### Data Transforming Class Method Unit Tests ###
      #################################################

      describe "Data Transforming class methods" do

        describe "#mime_data_from_email_data" do

          it 'returns the mime data of the email data' do
            expect( YahooMailAccount.mime_data_from_email_data(yahoo_mail_data) ).to eq( original_data )
          end
        end #__End of describe "#mime_data_from_email_data"__

        describe "#email_raw_from_email_data" do

          it 'returns the raw email from the email data' do
            expected = true

            allow(Email).to receive(:email_raw_from_mime_data) { expected }

            expect( YahooMailAccount.email_raw_from_email_data(yahoo_mail_data) ).to eq( expected )
          end
        end #__End of describe "#email_raw_from_email_data"__

        describe "#init_email_from_email_data" do
          let(:email) { FactoryGirl.create(:email) }
          let(:imap_folder) { FactoryGirl.create(:imap_folder) }
          let(:uid_value) { rand(10) }

          it 'saves the imap_folder.name + UID of the email data to the uid field of the email' do
            allow(yahoo_mail_data).to receive(:attr).and_return({ "UID" => uid_value, "FLAGS" => []})

            YahooMailAccount.init_email_from_email_data(email, yahoo_mail_data, imap_folder)

            expect( email.uid ).to eq( imap_folder.name + uid_value.to_s )
          end
        end #__End of describe "#init_email_from_email_data"__

      end

    end

    ##################################
    ### Instance Method Unit Tests ###
    ##################################

    describe "Instance methods" do

      #########################################
      ### Getter Instance Method Unit Tests ###
      #########################################

      describe "Getter instance methods" do

        describe '.o_auth2_token' do

          it "returns the Yahoo Mail account's yahoo_mail_o_auth2_token" do
            expect(yahoo_mail_account.o_auth2_token).to eq(yahoo_mail_account.yahoo_mail_o_auth2_token)
          end

        end

        describe '.smtp_address' do

          it "returns the yahoo mail account's SMTP_ADDRESS constant value" do
            expect(yahoo_mail_account.smtp_address).to eq(YahooMailAccount::SMTP_ADDRESS)
          end

        end

        describe '.imap_client' do
          before do
            yahoo_mail_client_stub = {}
            allow(yahoo_mail_account).to receive(:yahoo_mail_client) { yahoo_mail_client_stub }
          end

          it "returns the yahoo mail account's yahoo mail client" do
            expect(yahoo_mail_account.imap_client).to eq(yahoo_mail_account.yahoo_mail_client)
          end

        end

        describe '.yahoo_mail_client' do
          it "is pending spec implementation"
        end

        describe '.get_userinfo' do
          it "is pending spec implementation"
        end

        describe '.init_email_from_email_data' do
          it "is pending spec implementation"
        end

      end

      #########################################
      ### Setter Instance Method Unit Tests ###
      #########################################

      describe "Setter instance methods" do

        describe '.o_auth2_token' do
          it "is pending spec implementation"
        end

      end

      #######################################
      ### CRUD Instance Method Unit Tests ###
      #######################################

      describe "CRUD instance methods" do

        describe '.refresh_user_info' do
          it "is pending spec implementation"
        end

        describe '.delete_o_auth2_token' do
          context "when the yahoo_mail_o_auth2_token exists" do
            it 'destroys the delete_o_auth2_token' do

              yahoo_mail_account.delete_o_auth2_token

              expect( yahoo_mail_account.yahoo_mail_o_auth2_token ).to be(nil)
            end
          end #__End of context "when the yahoo_mail_o_auth2_token exists"__

        end #__End of describe ".delete_o_auth2_token"__

      end

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".sync_email_folders" do
          let!(:imap_folders) { FactoryGirl.create_list(:imap_folder, 5, email_account: yahoo_mail_account) }
          let!(:imap_folder_datas) { ["data 1", "data 2", "data 3", "data 4", "data 5"] }

          before do
            allow(yahoo_mail_account).to receive(:imap_folders_on_server).and_return(imap_folder_datas)
            allow(ImapFolder).to receive(:sync_imap_folder).and_return(imap_folders.sample)

            allow_any_instance_of(ImapFolder::ActiveRecord_Relation).to receive(:destroy_all)
          end

          it 'syncs the imap folder from the server' do
            yahoo_mail_account.sync_email_folders
            expect( ImapFolder ).to have_received(:sync_imap_folder).exactly(5).times
          end

          it 'destroys IMAP folders that are in the db and not on the Outlook server' do
            expect_any_instance_of(ImapFolder::ActiveRecord_Relation).to receive(:destroy_all)
            yahoo_mail_account.sync_email_folders
          end
        end

        describe ".sync_contacts" do

          it "does nothing" do
            expect(yahoo_mail_account.sync_contacts('token')).to eq(nil)
          end

        end

        describe ".sync_account" do
          before(:each) {
            allow(yahoo_mail_account).to receive(:sync_email_folders)
            allow(yahoo_mail_account).to receive(:sync_email)

            yahoo_mail_account.sync_account
          }

          it 'synchronizes the labels' do
            expect(yahoo_mail_account).to have_received(:sync_email_folders)
          end

          it 'synchronizes the email' do
            expect(yahoo_mail_account).to have_received(:sync_email)
          end

          it 'updates #last_sync_at attribute' do
            expect(yahoo_mail_account.last_sync_at).to be_within(1).of Time.now
          end

        end #__End of describe ".sync_account"__

      end

      #############################
      ### Email Synchronization ###
      #############################

      describe "Email Synchronization methods" do
        describe ".sync_email" do
          let!(:imap_folders) { FactoryGirl.create_list(:imap_folder, 5, email_account: yahoo_mail_account) }

          describe "when the emails exists on server but not in db" do
            let!(:email_uids_on_server) { ['uid-1', 'uid-2'] }
            let!(:email_uids_on_server_and_not_in_db) { ['server-uid-1', 'server-uid-2'] }
            let!(:emails) { FactoryGirl.create_list(:email, 2) }

            before do
              allow(yahoo_mail_account).to receive(:threads_in_imap_folder).and_return([])
              allow(yahoo_mail_account).to receive(:email_uids_in_imap_folder).and_return(email_uids_on_server)
              allow(yahoo_mail_account).to receive(:email_data_for_email_uids).and_return(email_uids_on_server_and_not_in_db)
              allow(yahoo_mail_account).to receive(:create_email_from_email_data).and_return(emails)
              allow(yahoo_mail_account).to receive(:get_thread_id).and_return(emails.first.uid)
            end

            it 'creates the emails in db' do
              yahoo_mail_account.sync_email
              expect(yahoo_mail_account).to have_received(:create_email_from_email_data).exactly(10).times
            end
          end

          describe "when the emails exists in db but not on server" do
            let!(:emails) { FactoryGirl.create_list(:email, 2) }

            before do
              imap_folders.each do |imap_folder|
                emails.each do |email|
                  FactoryGirl.create(:email_folder_mapping, email_folder: imap_folder, email: email )
                end
              end

              @et = EmailThread.first
              allow(yahoo_mail_account).to receive(:threads_in_imap_folder).and_return([])
              allow(yahoo_mail_account).to receive(:email_uids_in_imap_folder).and_return([])
              allow_any_instance_of(Email).to receive(:email_thread).and_return(@et)
              allow(@et).to receive(:destroy)
            end

            it 'destroys the emails from the db' do
              yahoo_mail_account.sync_email
              expect(@et).to have_received(:destroy).exactly(10).times
            end
          end
        end #__End of describe ".sync_email"__

      end

    end

  end

end
