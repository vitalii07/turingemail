# == Schema Information
#
# Table name: email_threads
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  uid                :text
#  created_at         :datetime
#  updated_at         :datetime
#  emails_count       :integer
#

require 'rails_helper'

RSpec.describe EmailFolder, :type => :model do

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

        describe "self.update_counts" do
          let(:gmail_label) { FactoryGirl.create(:gmail_label) }

          context "when the skip_update_counts is false" do
            before(:each) {
              EmailFolder.skip_update_counts = false
            }

            it 'updates the num_threads and num_unread_threads fields' do

              queried_mappings = EmailFolderMapping.joins(:email).
                  where(:email_folder => gmail_label)

              mappings_count = queried_mappings.count('DISTINCT emails.email_thread_id')
              unread_count = queried_mappings.count('DISTINCT case when emails.seen then null else emails.email_thread_id end')

              EmailFolder.update_counts([gmail_label])

              expect(gmail_label.num_threads).to eq(mappings_count)
              expect(gmail_label.num_unread_threads).to eq(unread_count)
            end
          end #__End of context "when the skip_update_counts is false"__
        end

        describe "self.update_num_unread_threads" do
          let(:gmail_label) { FactoryGirl.create(:gmail_label) }

          context "when the skip_update_counts is false" do
            before(:each) {
              EmailFolder.skip_update_counts = false
            }

            it 'updates the num_unread_threads field' do

              queried_mappings = EmailFolderMapping.joins(:email)
                  .where(:email_folder => gmail_label)

              mappings_count = queried_mappings.count('DISTINCT "emails"."email_thread_id"')

              EmailFolder.update_num_unread_threads([gmail_label])
              expect(gmail_label.num_unread_threads).to eq(mappings_count)
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
          let(:second_email_account) { FactoryGirl.create(:gmail_account) }
          let(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => second_email_account) }
          let(:email) { FactoryGirl.create(:email, :email_account => second_email_account) }

          context 'without emails' do
            it 'returns the empty result' do
              expect( EmailFolder.get_sorted_paginated_threads(email_folder: gmail_label, last_email_thread: nil, dir: 'DESC', threads_per_page: 50, log: true).length ).to eq(0)
            end

            context "when the emails of the gmail_label exist" do

              it 'returns the empty result' do
                email
                allow(gmail_label).to receive(:emails) { Email.all }
                expect( EmailFolder.get_sorted_paginated_threads(email_folder: gmail_label).count ).to eq( 0 )
              end

            end

          end

          context 'with emails' do
            let!(:email_threads) { FactoryGirl.create_list(:email_thread, SpecMisc::MEDIUM_LIST_SIZE, :email_account => gmail_label.gmail_account) }

            before { create_email_thread_emails(email_threads, email_folder: gmail_label, num_emails: SpecMisc::MEDIUM_LIST_SIZE, do_sleep: false) }

            it 'returns the email threads' do
              allow(EmailThread).to receive(:find_by_sql) { email_threads }

              expect( EmailFolder.get_sorted_paginated_threads(email_folder: gmail_label, last_email_thread: email_threads.last, dir: 'DESC', threads_per_page: 50, log: true).count ).to eq(email_threads.count)
            end

          end

        end #__End of describe ".get_sorted_paginated_threads"__

      end

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".update_counts" do
          let(:gmail_label) { FactoryGirl.create(:gmail_label) }

          context "when the skip_update_counts is true" do
            it 'returns the nil' do
              EmailFolder.skip_update_counts = true

              expect(gmail_label.update_counts).to be(nil)
            end
          end

          context "when the skip_update_counts is false" do
            before(:each) {
              EmailFolder.skip_update_counts = false
            }

            it 'updates the num_threads and num_unread_threads fields' do

              folder_mappings = EmailFolderMapping.joins(:email)
              allow(EmailFolderMapping).to receive(:joins) { folder_mappings }

              queried_mappings = folder_mappings.where(:email_folder => gmail_label)
              allow(folder_mappings).to receive(:where) { queried_mappings }

              mappings_count = queried_mappings.count('DISTINCT emails.email_thread_id')
              unread_count = queried_mappings.count('DISTINCT case when emails.seen then null else emails.email_thread_id end')

              gmail_label.update_counts

              expect(gmail_label.num_threads).to eq(mappings_count)
              expect(gmail_label.num_unread_threads).to eq(unread_count)
            end
          end #__End of context "when the skip_update_counts is false"__
        end #__End of describe ".update_counts"__

        describe ".update_num_unread_threads" do
          let(:gmail_label) { FactoryGirl.create(:gmail_label) }

          context "when the skip_update_counts is true" do
            it 'returns the nil' do
              EmailFolder.skip_update_counts = true

              expect(gmail_label.update_num_unread_threads).to be(nil)
            end
          end

          context "when the skip_update_counts is false" do
            before(:each) {
              EmailFolder.skip_update_counts = false
            }

            it 'updates the num_unread_threads field' do

              folder_mappings = EmailFolderMapping.joins(:email)
              allow(EmailFolderMapping).to receive(:joins) { folder_mappings }

              queried_mappings = folder_mappings.where(:email_folder => gmail_label)
              allow(folder_mappings).to receive(:where) { queried_mappings }

              mappings_count = queried_mappings.count('DISTINCT "emails"."email_thread_id"')
              allow(queried_mappings).to receive(:count) { mappings_count }

              gmail_label.update_num_unread_threads

              expect(gmail_label.num_unread_threads).to eq(mappings_count)
            end
          end #__End of context "when the skip_update_counts is false"__
        end #__End of describe ".update_num_unread_threads"__

        describe '.apply_to_emails' do
          let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
          let!(:gmail_label) { FactoryGirl.create(:gmail_label, :gmail_account => gmail_account) }

          let!(:email) { FactoryGirl.create(:email) }
          let!(:email_thread) { FactoryGirl.create(:email_thread) }
          let!(:email_folder) { FactoryGirl.create(:gmail_label) }
          let!(:email_folder_mapping) { FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: email_folder) }

          context "when the emails are given" do
            let(:emails) { [email] }

            it 'returns the email folder mapping array' do
              allow(EmailFolderMapping).to receive(:find_or_create_by!) { email_folder_mapping }

              expect( gmail_label.apply_to_emails(emails) ).to eq( [email_folder_mapping] )
            end
          end #__End of context "when the emails are given"__

          context "when the email ids are given" do
            let(:email_ids) { [email.id] }

            it 'returns the email folder mapping array' do
              allow(EmailFolderMapping).to receive(:find_or_create_by!) { email_folder_mapping }

              expect( gmail_label.apply_to_emails(email_ids) ).to eq( [email_folder_mapping] )
            end
          end #__End of context "when the email ids are given"__

          context "when the exception is raised" do
            it 'returns the array of the nil' do
              allow(EmailFolderMapping).to receive(:find_or_create_by!) {
                FactoryGirl.create(:email, id: email.id)
              }

              expect( gmail_label.apply_to_emails([email]) ).to eq( [nil] )
            end

          end

        end #__End of describe ".apply_to_emails"__

      end

    end

  end

end