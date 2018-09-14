require 'rails_helper'
require 'stringio'

RSpec.describe ImapEmailAccount, :type => :model do
  let!(:outlook_account) { FactoryGirl.create(:outlook_account) }
  let(:original_data) { "original outlook data" }
  let(:encoded_data) { Base64.urlsafe_encode64(original_data) }
  let(:outlook_data) { {:raw => encoded_data} }

  ###########################
  ### Constant Unit Tests ###
  ###########################

  describe "Contants" do

    describe "::MESSAGE_BATCH_SIZE" do
      it 'returns 100' do
        expect( ImapEmailAccount::MESSAGE_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::DRAFTS_BATCH_SIZE" do
      it 'returns 100' do
        expect( ImapEmailAccount::DRAFTS_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::HISTORY_BATCH_SIZE" do
      it 'returns 100' do
        expect( ImapEmailAccount::HISTORY_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::SEARCH_RESULTS_PER_PAGE" do
      it 'returns 50' do
        expect( ImapEmailAccount::SEARCH_RESULTS_PER_PAGE ).to eq( 50 )
      end
    end

    describe "::NUM_SYNC_DYNOS" do
      it 'returns 3' do
        expect( ImapEmailAccount::NUM_SYNC_DYNOS ).to eq( 3 )
      end
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

        describe ".email_folders" do
          let!(:imap_email_account_with_imap_folders) { FactoryGirl.create(:outlook_account_with_imap_folders) }

          it "returns the imap folders for the email account" do
            queries_imap_folders = ImapFolder.where(:email_account => imap_email_account_with_imap_folders)
            expect(imap_email_account_with_imap_folders.email_folders).to eq(queries_imap_folders)
          end

        end

        describe ".message_list" do

          it 'calls the messages_list method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:messages_list)

            outlook_account.message_list

            expect( imap_client ).to have_received(:messages_list)
          end

        end

        describe ".message_get" do

          it 'calls the message_get method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:messages_get)

            outlook_account.message_get(1)

            expect( imap_client ).to have_received(:messages_get).with(1)
          end

        end

        describe ".drafts_list" do

          it 'calls the drafts_list method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:drafts_list)

            outlook_account.drafts_list([1])

            expect( imap_client ).to have_received(:drafts_list).with([1])
          end

        end

        describe ".imap_folders_on_server" do

          it 'calls the imap_folders_list method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:imap_folders_list)

            outlook_account.imap_folders_on_server

            expect( imap_client ).to have_received(:imap_folders_list)
          end

        end

        describe ".email_uids_in_imap_folder" do

          it 'calls the imap_folders_list method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:email_uids_in_imap_folder)

            outlook_account.email_uids_in_imap_folder("INBOX")

            expect( imap_client ).to have_received(:email_uids_in_imap_folder).with("INBOX")
          end

        end

        describe ".labels_create" do

          it 'calls the labels_create method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:labels_create)

            outlook_account.labels_create("Test Label")

            expect( imap_client ).to have_received(:labels_create).with("Test Label")
          end

        end

        describe ".labels_get" do

          it 'calls the labels_get method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:labels_get)

            outlook_account.labels_get("Test Label")

            expect( imap_client ).to have_received(:labels_get).with("Test Label")
          end

        end

        describe ".labels_list" do

          it 'calls the labels_list method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:labels_list)

            outlook_account.labels_list

            expect( imap_client ).to have_received(:labels_list)
          end

        end

        describe ".email_data_for_email_uids" do

          it 'calls the email_data_for_email_uids method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:email_data_for_email_uids)

            outlook_account.email_data_for_email_uids("INBOX", [1, 2])

            expect( imap_client ).to have_received(:email_data_for_email_uids).with("INBOX", [1, 2])
          end

        end

        describe ".attachments_get" do

          it 'calls the attachments_get method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:attachments_get)

            outlook_account.attachments_get(1, 2)

            expect( imap_client ).to have_received(:attachments_get).with(1, 2)
          end

        end

      end

      #######################################
      ### CRUD Instance Method Unit Tests ###
      #######################################

      describe "CRUD instance methods" do

        describe ".create_email_from_email_data" do
          it "is pending spec implementation"
        end

        describe ".messages_trash" do

          it 'calls the messages_trash method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:messages_trash)

            outlook_account.messages_trash([1, 2])

            expect( imap_client ).to have_received(:messages_trash).with([1, 2])
          end

        end

        describe ".drafts_delete" do

          it 'calls the drafts_delete method of the imap client' do
            imap_client = {}

            allow(outlook_account).to receive(:imap_client) { imap_client }
            allow(imap_client).to receive(:drafts_delete)

            outlook_account.drafts_delete([1, 2])

            expect( imap_client ).to have_received(:drafts_delete).with([1, 2])
          end

        end

      end

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".sync_email_folders" do
          let!(:imap_folders) { FactoryGirl.create_list(:imap_folder, 5, email_account: outlook_account) }
          let!(:imap_folder_datas) { ["data 1", "data 2", "data 3", "data 4", "data 5"] }

          before do
            allow(outlook_account).to receive(:imap_folders_on_server).and_return(imap_folder_datas)
            allow(ImapFolder).to receive(:sync_imap_folder).and_return(imap_folders.sample)

            allow_any_instance_of(ImapFolder::ActiveRecord_Relation).to receive(:destroy_all)
          end

          it 'syncs the imap folder from the server' do
            outlook_account.sync_email_folders
            expect( ImapFolder ).to have_received(:sync_imap_folder).exactly(5).times
          end

          it 'destroys IMAP folders that are in the db and not on the Outlook server' do
            expect_any_instance_of(ImapFolder::ActiveRecord_Relation).to receive(:destroy_all)
            outlook_account.sync_email_folders
          end
        end

        describe ".sync_contacts" do

          it "does nothing" do
            expect(outlook_account.sync_contacts('token')).to eq(nil)
          end

        end

        describe ".sync_account" do
          before(:each) {
            allow(outlook_account).to receive(:sync_email_folders)
            allow(outlook_account).to receive(:sync_email)

            outlook_account.sync_account
          }

          it 'synchronizes the labels' do
            expect(outlook_account).to have_received(:sync_email_folders)
          end

          it 'synchronizes the email' do
            expect(outlook_account).to have_received(:sync_email)
          end

          it 'updates #last_sync_at attribute' do
            expect(outlook_account.last_sync_at).to be_within(1).of Time.now
          end

        end #__End of describe ".sync_account"__

      end

      #############################
      ### Email Synchronization ###
      #############################

      describe "Email Synchronization methods" do
        describe ".sync_email" do
          let!(:imap_folders) { FactoryGirl.create_list(:imap_folder, 5, email_account: outlook_account) }

          describe "when the emails exists on server but not in db" do
            let!(:email_uids_on_server) { ['uid-1', 'uid-2'] }
            let!(:email_uids_on_server_and_not_in_db) { ['server-uid-1', 'server-uid-2'] }
            let!(:emails) { FactoryGirl.create_list(:email, 2) }

            before do
              allow(outlook_account).to receive(:threads_in_imap_folder).and_return([])
              allow(outlook_account).to receive(:email_uids_in_imap_folder).and_return(email_uids_on_server)
              allow(outlook_account).to receive(:email_data_for_email_uids).and_return(email_uids_on_server_and_not_in_db)
              allow(outlook_account).to receive(:create_email_from_email_data).and_return(emails)
              allow(outlook_account).to receive(:create_email_from_email_data).and_return(emails)
              allow(outlook_account).to receive(:get_thread_id).and_return(emails.first.uid)
            end

            it 'creates the emails in db' do
              outlook_account.sync_email
              expect(outlook_account).to have_received(:create_email_from_email_data).exactly(10).times
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
              allow(outlook_account).to receive(:threads_in_imap_folder).and_return([])
              allow(outlook_account).to receive(:email_uids_in_imap_folder).and_return([])
              allow_any_instance_of(Email).to receive(:email_thread).and_return(@et)
              allow(@et).to receive(:destroy)
            end

            it 'destroys the emails from the db' do
              outlook_account.sync_email
              expect(@et).to have_received(:destroy).exactly(10).times
            end
          end
        end #__End of describe ".sync_email"__

      end
    end

  end

end