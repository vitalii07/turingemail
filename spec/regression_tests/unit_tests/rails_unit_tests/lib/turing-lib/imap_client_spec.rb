require 'rails_helper'

RSpec.describe ImapClient do
  class RealClient < ImapClient
    IMAP_URL = 'imap-mail.outlook.com'
    attr_accessor :imap
  end

  #################
  ### Constants ###
  #################

  describe "Contants" do

    describe "::UID_BLOCK_SIZE" do
      it 'returns 1024' do
        expect( ImapClient::UID_BLOCK_SIZE ).to eq( 1024 )
      end
    end
  end

  #####################
  ### Class Methods ###
  #####################

  describe "Class Methods" do
    describe "#credentials_can_authenticate?" do
      let!(:username) { "user name" }
      let!(:password) { "password" }

      before do
        allow_any_instance_of(Net::IMAP).to receive(:authenticate)
      end

      it 'checks if the credential can authenticate' do
        expect_any_instance_of(Net::IMAP).to receive(:authenticate).with('PLAIN', username, password)
        RealClient.credentials_can_authenticate?(username, password)
      end

      it 'returns true' do
        expect( RealClient.credentials_can_authenticate?(username, password) ).to be true
      end
    end
  end

  ########################
  ### Instance Methods ###
  ########################

  describe "Instance Methods" do
    let!(:email_account) { FactoryGirl.create(:outlook_account) }
    let!(:outlook_o_auth2_token) { FactoryGirl.create(:outlook_o_auth2_token, api: email_account) }

    before do
      allow_any_instance_of(Net::IMAP).to receive(:authenticate)
    end

    describe ".initialize" do
      before do
        allow_any_instance_of(ImapClient).to receive(:authenticate)
      end

      it 'sets the imap attribute' do
        imap_client = RealClient.new(email_account)
        expect(imap_client.imap).to be_kind_of(Net::IMAP)
      end

      it 'authenticates the email account' do
        expect_any_instance_of(ImapClient).to receive(:authenticate).with(email_account)
        imap_client = RealClient.new(email_account)
      end
    end

    ######################
    ### Authentication ###
    ######################

    describe "Authentication" do
      describe ".authenticate" do
        before do
          allow_any_instance_of(ImapClient).to receive(:authenticate_with_xoauth2)
        end

        it 'authenticates the email account' do
          expect_any_instance_of(ImapClient).to receive(:authenticate_with_xoauth2).with(email_account)
          imap_client = RealClient.new(email_account)
          imap_client.authenticate(email_account)
        end
      end

      describe ".authenticate_with_xoauth2" do
        it 'authenticates the email account with xoauth2' do
          expect_any_instance_of(Net::IMAP).to receive(:authenticate).with('XOAUTH2', email_account.email, email_account.o_auth2_token.access_token)
          imap_client = RealClient.new(email_account)
        end
      end
    end

    ####################
    ### IMAP Folders ###
    ####################

    describe "IMAP Folders" do
      let!(:imap_client) { RealClient.new(email_account) }

      describe ".imap_folders_list" do
        before do
          allow_any_instance_of(Net::IMAP).to receive(:list)
        end

        it 'returns the list of the imap folder' do
          expect_any_instance_of(Net::IMAP).to receive(:list).with("", "**")
          imap_client.imap_folders_list
        end
      end

      describe ".labels_create" do
        let!(:name) { "example name" }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:create)
        end

        it 'creats the label' do
          expect_any_instance_of(Net::IMAP).to receive(:create).with(name)
          imap_client.labels_create(name)
        end
      end

      describe ".labels_list" do
        before do
          allow_any_instance_of(Net::IMAP).to receive(:list)
        end

        it 'returns the list of the imap folder' do
          expect_any_instance_of(Net::IMAP).to receive(:list).with('', '%')
          imap_client.labels_list
        end
      end

      describe ".labels_get" do
        let!(:name) { "example name" }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:select)
          allow_any_instance_of(Net::IMAP).to receive(:status)
        end

        it 'selects the label' do
          expect_any_instance_of(Net::IMAP).to receive(:select).with(name)
          imap_client.labels_get(name)
        end

        it 'gets the labels' do
          expect_any_instance_of(Net::IMAP).to receive(:status).with(name, ["MESSAGES", "RECENT", "UNSEEN"])
          imap_client.labels_get(name)
        end
      end
    end

    ################
    ### Messages ###
    ################

    describe "Messages" do
      let!(:imap_client) { RealClient.new(email_account) }

      describe ".email_uids_in_imap_folder" do
        let!(:folder_name) { "folder name" }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:examine)
          allow_any_instance_of(Net::IMAP).to receive(:uid_search)
        end

        it 'examines the folder' do
          expect_any_instance_of(Net::IMAP).to receive(:examine).with(folder_name)
          imap_client.email_uids_in_imap_folder(folder_name)
        end

        it 'searches the uids' do
          expect_any_instance_of(Net::IMAP).to receive(:uid_search).with(['ALL'])
          imap_client.email_uids_in_imap_folder(folder_name)
        end
      end

      describe ".email_data_for_email_uids" do
        let!(:folder_name) { "folder name" }
        let!(:email_uids) { ['uid-1', 'uid-2'] }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:examine)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch)
        end

        it 'examines the folder' do
          expect_any_instance_of(Net::IMAP).to receive(:examine).with(folder_name)
          imap_client.email_data_for_email_uids(folder_name, email_uids)
        end

        it 'fetches the email data' do
          expect_any_instance_of(Net::IMAP).to receive(:uid_fetch).with(email_uids, ['RFC822'])
          imap_client.email_data_for_email_uids(folder_name, email_uids)
        end
      end

      describe ".messages_list" do
        let!(:uids) { ["uid-1", "uid-2", "uid-3", "uid-4", "uid-5"] }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:examine)
          allow_any_instance_of(Net::IMAP).to receive(:uid_search).and_return(uids)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch).and_return(uids)
        end

        it 'examines INBOX' do
          expect_any_instance_of(Net::IMAP).to receive(:examine).with('INBOX')
          imap_client.messages_list
        end

        context "without maxResults" do
          it 'returns all the messages' do
            expect(imap_client.messages_list).to eq(uids)
          end
        end

        context "with maxResults" do
          let!(:maxResults) { 3 }
          before do
            allow(uids).to receive(:take).and_return(uids)
          end

          it 'returns the given number of messages' do
            imap_client.messages_list(maxResults)
            expect(uids).to have_received(:take).with(maxResults)
          end
        end
      end

      describe ".messages_get" do
        let!(:id) { "uid" }
        let!(:messages) { ["message 1", "message 2", "message 3"] }

        before do
          allow_any_instance_of(Net::IMAP).to receive(:examine)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch).and_return(messages)
        end

        it 'examines INBOX' do
          expect_any_instance_of(Net::IMAP).to receive(:examine).with('INBOX')
          imap_client.messages_get(id)
        end

        it 'returns the message with the id' do
          expect( imap_client.messages_get(id) ).to eq messages.first
        end
      end

      describe ".messages_trash" do
        let!(:ids) { ["uid-1", "uid-2", "uid-3"] }
        let!(:trash_folder_name) { "trash folder name" }

        before do
          allow_any_instance_of(Net::IMAP).to receive(:select)
          allow_any_instance_of(Net::IMAP).to receive(:uid_copy)
          allow_any_instance_of(Net::IMAP).to receive(:uid_store)
          allow_any_instance_of(Net::IMAP).to receive(:expunge)
        end

        it 'selects INBOX' do
          expect_any_instance_of(Net::IMAP).to receive(:select).with(trash_folder_name)
          imap_client.messages_trash(ids, trash_folder_name)
        end

        it 'trashes the messages' do
          expect_any_instance_of(Net::IMAP).to receive(:expunge)
          imap_client.messages_trash(ids, trash_folder_name)
        end
      end

      describe ".messages_get_by_message_id" do
        let!(:message_id) { "message-id" }
        let!(:folder_name) { "folder name" }
        let!(:found_uid) { "founded-id" }
        let!(:message) { "founded message" }

        before do
          allow_any_instance_of(Net::IMAP).to receive(:examine)
          allow_any_instance_of(Net::IMAP).to receive(:uid_search).and_return(found_uid)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch).and_return(message)
        end

        it 'examines INBOX' do
          expect_any_instance_of(Net::IMAP).to receive(:examine).with(folder_name)
          imap_client.messages_get_by_message_id(message_id, folder_name)
        end

        it 'returns the messages by the message id' do
          expect( imap_client.messages_get_by_message_id(message_id, folder_name) ).to eq message
        end
      end

      describe ".message_create" do
        let!(:email_raw) { "raw email" }
        let!(:folder_name) { "folder name" }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:append)
        end

        it 'creates the message' do
          expect_any_instance_of(Net::IMAP).to receive(:append).with(folder_name, email_raw)
          imap_client.message_create(email_raw, folder_name)
        end
      end
    end

    ##############
    ### Drafts ###
    ##############

    describe "Drafts" do
      let!(:imap_client) { RealClient.new(email_account) }

      class RawMessage
        def initialize(envelop=nil)
          @envelop = envelop
        end

        def attr
          {"ENVELOPE" => @envelop}
        end

        def seqno
          1
        end
      end

      describe ".drafts_create" do
        let!(:email_raw) { "raw email" }
        let!(:drafts_folder_name) { "drafts folder name" }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:append)
        end

        it 'creates the drafts' do
          expect_any_instance_of(Net::IMAP).to receive(:append).with(drafts_folder_name, email_raw)
          imap_client.drafts_create(email_raw, drafts_folder_name)
        end
      end

      describe ".drafts_list" do
        let!(:uids) { ["uid-1", "uid-2", "uid-3", "uid-4", "uid-5"] }
        let!(:maxResults) { 3 }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:examine)
          allow_any_instance_of(Net::IMAP).to receive(:uid_search).and_return(uids)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch).and_return(uids)
          allow(uids).to receive(:take).and_return(uids)
        end

        it 'examines Drafts' do
          expect_any_instance_of(Net::IMAP).to receive(:examine).with('Drafts')
          imap_client.drafts_list(maxResults)
        end

        it 'returns the given number of drafts' do
          imap_client.drafts_list(maxResults)
          expect(uids).to have_received(:take).with(maxResults)
        end
      end
    end

    ###############
    ### Threads ###
    ###############

    describe "Threads" do
      let!(:imap_client) { RealClient.new(email_account) }

      describe ".threads_list" do
        class Envelop
          def subject
            'subject'
          end
          def message_id
            'message-id'
          end
          def in_reply_to
            'in reply to'
          end
          def from
            'from@email.com'
          end
        end
        let!(:uids) { ["uid-1", "uid-2", "uid-3", "uid-4", "uid-5"] }
        let!(:msg_list) { [RawMessage.new(Envelop.new)] }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:examine)
          allow_any_instance_of(Net::IMAP).to receive(:uid_search).and_return(uids)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch).and_return(msg_list)
        end

        it 'examines the INBOX' do
          expect_any_instance_of(Net::IMAP).to receive(:examine).with('INBOX')
          imap_client.threads_list("INBOX")
        end

        xit 'returns the threads' do
          expect(imap_client.threads_list("INBOX")).to eq msg_list
        end

      end

      describe ".threads_in_imap_folder" do
        let!(:uids) { ["uid-1", "uid-2", "uid-3", "uid-4", "uid-5"] }
        let!(:folder_name) { "my folder" }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:examine)
          allow_any_instance_of(Net::IMAP).to receive(:uid_thread).and_return(uids)
        end

        it 'examines the folder' do
          expect_any_instance_of(Net::IMAP).to receive(:examine).with(folder_name)
          imap_client.threads_in_imap_folder(folder_name)
        end

        it 'returns the threads in the folder' do
          expect_any_instance_of(Net::IMAP).to receive(:uid_thread).with("REFERENCES", ['ALL'], "UTF-8")
          imap_client.threads_in_imap_folder(folder_name)
        end
      end

      describe ".attachments_get" do
        let!(:label_id) { "label-id" }
        let!(:message_id) { "message-id" }
        let!(:msg) {
          {
            "attr" => {
              "BODY" => "message body"
            }
          }
        }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:select)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch).and_return(msg)
        end

        it 'selects the label' do
          expect_any_instance_of(Net::IMAP).to receive(:select).with(label_id)
          imap_client.attachments_get(label_id, message_id)
        end

        it 'returns the threads in the folder' do
          expect(imap_client.attachments_get(label_id, message_id)).to eq msg["attr"]["BODY"]
        end
      end

      describe ".move_email_to_folder" do
        let!(:email) { FactoryGirl.create(:email) }
        let!(:current_folder) { FactoryGirl.create(:imap_folder, delim: "current delim") }
        let!(:to_folder) { FactoryGirl.create(:imap_folder, delim: "to delim") }
        let!(:email_thread) { FactoryGirl.create(:email_thread) }
        let!(:email_folder) { FactoryGirl.create(:gmail_label) }
        let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: current_folder)  }
        let!(:raw_messages) {
          [RawMessage.new]
        }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:select)
          allow_any_instance_of(Net::IMAP).to receive(:list)
          allow_any_instance_of(Net::IMAP).to receive(:create)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch).and_return(raw_messages)
          allow_any_instance_of(Net::IMAP).to receive(:copy)
          allow_any_instance_of(Net::IMAP).to receive(:store)
          allow_any_instance_of(Net::IMAP).to receive(:expunge)
        end

        it 'selects the folder' do
          current_folder_delim = current_folder.delim
          current_folder_delim[0] = "" if current_folder_delim[0] == "/"
          expect_any_instance_of(Net::IMAP).to receive(:select).with(current_folder_delim + current_folder.name)
          imap_client.move_email_to_folder(email, current_folder, to_folder)
        end

        it 'creates the to folder' do
          to_folder_delim = to_folder.delim
          to_folder_delim[0] = "" if to_folder_delim[0] == "/"
          expect_any_instance_of(Net::IMAP).to receive(:create).with(to_folder_delim + to_folder.name)
          imap_client.move_email_to_folder(email, current_folder, to_folder)
        end

        it 'copys the current folder' do
          expect_any_instance_of(Net::IMAP).to receive(:copy)
          imap_client.move_email_to_folder(email, current_folder, to_folder)
        end

        it 'stores the copied folder' do
          expect_any_instance_of(Net::IMAP).to receive(:store)
          imap_client.move_email_to_folder(email, current_folder, to_folder)
        end

        it 'expunges' do
          expect_any_instance_of(Net::IMAP).to receive(:expunge)
          imap_client.move_email_to_folder(email, current_folder, to_folder)
        end
      end

      describe ".set_seen" do
        let!(:email) { FactoryGirl.create(:email) }
        let!(:current_folder) { FactoryGirl.create(:imap_folder, delim: "current delim") }
        let!(:email_thread) { FactoryGirl.create(:email_thread) }
        let!(:email_folder) { FactoryGirl.create(:gmail_label) }
        let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: current_folder)  }
        let!(:raw_messages) { [RawMessage.new] }
        let!(:message_sequence_number) { raw_messages.first.seqno }
        before do
          allow_any_instance_of(Net::IMAP).to receive(:select)
          allow_any_instance_of(Net::IMAP).to receive(:uid_fetch).and_return(raw_messages)
          allow_any_instance_of(Net::IMAP).to receive(:store)
          allow_any_instance_of(Net::IMAP).to receive(:expunge)
        end

        it 'selects the folder' do
          expect_any_instance_of(Net::IMAP).to receive(:select)
          imap_client.set_seen(email, true)
        end

        context 'when the seen is true' do
          it 'sets the true' do
            expect_any_instance_of(Net::IMAP).to receive(:store).with(message_sequence_number, "+FLAGS", [:SEEN])
            imap_client.set_seen(email, true)
          end
        end

        context 'when the seen is false' do
          it 'sets the false' do
            expect_any_instance_of(Net::IMAP).to receive(:store)#.with(message_sequence_number, "-FLAGS", [:SEEN])
            imap_client.set_seen(email, false)
          end
        end

        it 'expunges' do
          expect_any_instance_of(Net::IMAP).to receive(:expunge)
          imap_client.set_seen(email, true)
        end
      end

    end
  end
end

