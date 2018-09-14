# == Schema Information
#
# Table name: imap_folders
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  name               :text
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

RSpec.describe ImapFolder, :type => :model do
  let!(:email_account) { FactoryGirl.create(:outlook_account) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_account_id).of_type(:integer)  }
      it { should have_db_column(:email_account_type).of_type(:string)  }
      it { should have_db_column(:name).of_type(:text)  }
      it { should have_db_column(:delim).of_type(:string)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
      it { should have_db_column(:num_threads).of_type(:integer)  }
      it { should have_db_column(:num_unread_threads).of_type(:integer)  }
    end

    describe "Indexes" do
      it { should have_db_index([:email_account_id, :email_account_type, :name]).unique(true) }
      it { should have_db_index([:email_account_id, :email_account_type]) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :email_account }
    end

    describe "Have many relationships" do
      it { should have_many(:email_folder_mappings).dependent(:destroy) }
      it { should have_many(:emails) }
      it { should have_many(:email_threads).through(:emails) }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:email_account_id) }
      it { should validate_presence_of(:email_account_type) }
      it { should validate_presence_of(:name) }
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

        describe "#skip_update_counts" do
          it 'returns the skip_update_counts' do
            expected = true
            EmailFolder.skip_update_counts = expected

            expect(EmailFolder.skip_update_counts).to eq(expected)
          end
        end #__End of describe "#skip_update_counts"__

      end

      ######################################
      ### Setter Class Method Unit Tests ###
      ######################################

      describe "Setter class methods" do

        describe "#skip_update_counts=" do
          it 'sets the skip_update_counts' do
            expected = true
            EmailFolder.skip_update_counts = expected

            expect(EmailFolder.skip_update_counts).to eq(expected)
          end
        end #__End of describe "#skip_update_counts="__

      end

      ######################################
      ### Action Class Method Unit Tests ###
      ######################################

      describe "Action class methods" do

        describe "self.sync_imap_folder" do
          it "is pending spec implementation"
        end

        describe "self.update_counts" do
          let(:imap_folder) { FactoryGirl.create(:imap_folder) }

          context "when the skip_update_counts is false" do
            before(:each) {
              EmailFolder.skip_update_counts = false
            }

            it 'updates the num_threads and num_unread_threads fields' do

              queried_mappings = EmailFolderMapping.joins(:email).
                  where(:email_folder => imap_folder)

              mappings_count = queried_mappings.count('DISTINCT emails.email_thread_id')
              unread_count = queried_mappings.count('DISTINCT case when emails.seen then null else emails.email_thread_id end')

              EmailFolder.update_counts([imap_folder])

              expect(imap_folder.num_threads).to eq(mappings_count)
              expect(imap_folder.num_unread_threads).to eq(unread_count)
            end
          end #__End of context "when the skip_update_counts is false"__
        end

        describe "self.update_num_unread_threads" do
          let(:imap_folder) { FactoryGirl.create(:imap_folder) }

          context "when the skip_update_counts is false" do
            before(:each) {
              EmailFolder.skip_update_counts = false
            }

            it 'updates the num_unread_threads field' do

              queried_mappings = EmailFolderMapping.joins(:email)
                  .where(:email_folder => imap_folder)

              mappings_count = queried_mappings.count('DISTINCT "emails"."email_thread_id"')

              EmailFolder.update_num_unread_threads([imap_folder])
              expect(imap_folder.num_unread_threads).to eq(mappings_count)
            end
          end #__End of context "when the skip_update_counts is false"__
        end #__End of describe ".update_num_unread_threads"__

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

        describe '.get_sorted_paginated_threads' do
          let(:second_email_account) { FactoryGirl.create(:outlook_account) }
          let(:imap_folder) { FactoryGirl.create(:imap_folder, :email_account => second_email_account) }
          let(:email) { FactoryGirl.create(:email, :email_account => second_email_account) }

          context 'without emails' do
            it 'returns the empty result' do
              expect( ImapFolder.get_sorted_paginated_threads(email_folder: imap_folder, last_email_thread: nil, dir: 'DESC', threads_per_page: 50, log: true).length ).to eq(0)
            end

            context "when the emails of the imap_folder exist" do

              it 'returns the empty result' do
                email
                allow(imap_folder).to receive(:emails) { Email.all }
                expect( ImapFolder.get_sorted_paginated_threads(email_folder: imap_folder).count ).to eq( 0 )
              end
            end
          end

          context 'with emails' do
            let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => imap_folder.email_account) }

            before { create_email_thread_emails(email_threads, email_folder: imap_folder, num_emails: SpecMisc::MEDIUM_LIST_SIZE, do_sleep: false) }

            it 'returns the email threads' do
              allow(EmailThread).to receive(:find_by_sql) { email_threads }

              expect( ImapFolder.get_sorted_paginated_threads(email_folder: imap_folder, last_email_thread: email_threads.last, dir: 'DESC', threads_per_page: 50, log: true).count ).to eq(email_threads.count)
            end
          end
        end #__End of describe ".get_sorted_paginated_threads"__

        ##############################################
        ### Boolean Getter Class Method Unit Tests ###
        ##############################################

        describe "Boolean getter class methods" do

          describe '.is_system_folder?' do
            let!(:yahoo_mail_account) { FactoryGirl.create(:yahoo_mail_account) }
            let(:imap_folder) { FactoryGirl.create(:imap_folder, :email_account => yahoo_mail_account) }

            describe "when the folder name is a system folder name" do

              YahooMailAccount::SYSTEM_FOLDERS.values.each do |folder_name|

                describe "when the folder name is " + folder_name do
                  before { imap_folder.update_attribute(:name, folder_name)}

                  it "returns true" do
                    expect(imap_folder.is_system_folder?).to be(true)
                  end

                end

              end

            end

            describe "when the folder name is not a system folder name" do
              before { imap_folder.name = "random name "}

              it "returns false" do
                expect(imap_folder.is_system_folder?).to be(false)
              end

            end

          end

        end

      end

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".update_counts" do
          let(:imap_folder) { FactoryGirl.create(:imap_folder) }

          context "when the skip_update_counts is true" do
            it 'returns the nil' do
              EmailFolder.skip_update_counts = true

              expect(imap_folder.update_counts).to be(nil)
            end
          end

          context "when the skip_update_counts is false" do
            before(:each) {
              EmailFolder.skip_update_counts = false
            }

            it 'updates the num_threads and num_unread_threads fields' do

              folder_mappings = EmailFolderMapping.joins(:email)
              allow(EmailFolderMapping).to receive(:joins) { folder_mappings }

              queried_mappings = folder_mappings.where(:email_folder => imap_folder)
              allow(folder_mappings).to receive(:where) { queried_mappings }

              mappings_count = queried_mappings.count('DISTINCT emails.email_thread_id')
              unread_count = queried_mappings.count('DISTINCT case when emails.seen then null else emails.email_thread_id end')

              imap_folder.update_counts

              expect(imap_folder.num_threads).to eq(mappings_count)
              expect(imap_folder.num_unread_threads).to eq(unread_count)
            end
          end #__End of context "when the skip_update_counts is false"__
        end #__End of describe ".update_counts"__

        describe ".update_num_unread_threads" do
          let(:imap_folder) { FactoryGirl.create(:imap_folder) }

          context "when the skip_update_counts is true" do
            it 'returns the nil' do
              EmailFolder.skip_update_counts = true

              expect(imap_folder.update_num_unread_threads).to be(nil)
            end
          end

          context "when the skip_update_counts is false" do
            before(:each) {
              EmailFolder.skip_update_counts = false
            }

            it 'updates the num_unread_threads field' do

              folder_mappings = EmailFolderMapping.joins(:email)
              allow(EmailFolderMapping).to receive(:joins) { folder_mappings }

              queried_mappings = folder_mappings.where(:email_folder => imap_folder)
              allow(folder_mappings).to receive(:where) { queried_mappings }

              mappings_count = queried_mappings.count('DISTINCT "emails"."email_thread_id"')
              allow(queried_mappings).to receive(:count) { mappings_count }

              imap_folder.update_num_unread_threads

              expect(imap_folder.num_unread_threads).to eq(mappings_count)
            end
          end #__End of context "when the skip_update_counts is false"__
        end #__End of describe ".update_num_unread_threads"__

        describe '.apply_to_emails' do
          let!(:outlook_account) { FactoryGirl.create(:outlook_account) }
          let!(:imap_folder) { FactoryGirl.create(:imap_folder, :email_account => outlook_account) }

          let!(:email) { FactoryGirl.create(:email) }
          let!(:email_thread) { FactoryGirl.create(:email_thread) }
          let!(:email_folder) { FactoryGirl.create(:imap_folder) }
          let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: email_folder) }

          context "when the emails are given" do
            let(:emails) { [email] }

            it 'returns the email folder mapping array' do
              allow(EmailFolderMapping).to receive(:find_or_create_by!) { email_folder_mapping }

              expect( imap_folder.apply_to_emails(emails) ).to eq( [email_folder_mapping] )
            end
          end #__End of context "when the emails are given"__

          context "when the email ids are given" do
            let(:email_ids) { [email.id] }

            it 'returns the email folder mapping array' do
              allow(EmailFolderMapping).to receive(:find_or_create_by!) { email_folder_mapping }

              expect( imap_folder.apply_to_emails(email_ids) ).to eq( [email_folder_mapping] )
            end
          end #__End of context "when the email ids are given"__

          context "when the exception is raised" do
            it 'returns the array of the nil' do
              allow(EmailFolderMapping).to receive(:find_or_create_by!) {
                FactoryGirl.create(:email, id: email.id)
              }

              expect( imap_folder.apply_to_emails([email]) ).to eq( [nil] )
            end
          end
        end #__End of describe ".apply_to_emails"__

      end

    end

  end

end
