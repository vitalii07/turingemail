require 'rails_helper'
require 'stringio'

RSpec.describe EmailAccount, :type => :model do
  let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
  let(:original_data) { "original gmail data" }
  let(:encoded_data) { Base64.urlsafe_encode64(original_data) }
  let(:gmail_data) { {:raw => encoded_data} }
  let(:google_o_auth2_token) { FactoryGirl.create(:google_o_auth2_token) }

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

  ###########################
  ### Constant Unit Tests ###
  ###########################

  describe "Contants" do

    describe "::MESSAGE_BATCH_SIZE" do
      it 'returns 100' do
        expect( EmailAccount::MESSAGE_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::DRAFTS_BATCH_SIZE" do
      it 'returns 100' do
        expect( EmailAccount::DRAFTS_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::HISTORY_BATCH_SIZE" do
      it 'returns 100' do
        expect( EmailAccount::HISTORY_BATCH_SIZE ).to eq( 100 )
      end
    end

    describe "::SEARCH_RESULTS_PER_PAGE" do
      it 'returns 50' do
        expect( EmailAccount::SEARCH_RESULTS_PER_PAGE ).to eq( 50 )
      end
    end

    describe "::NUM_SYNC_DYNOS" do
      it 'returns 3' do
        expect( EmailAccount::NUM_SYNC_DYNOS ).to eq( 3 )
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

        describe ".find_sync_job" do
          it "is pending spec implementation"
        end

        #################################################
        ### Boolean Getter Instance Method Unit Tests ###
        #################################################

        describe "Boolean getter instance methods" do

          describe ".active?" do
            let!(:user) { FactoryGirl.create(:user_with_gmail_accounts) }

            describe "when the user is suspended" do
              before do
                allow(user.current_email_account()).to receive(:suspended?) { true }
              end

              it "return false" do
                expect(user.current_email_account().active?).to be(false)
              end

            end

            describe "when the user is not suspended" do
              before do
                allow(user.current_email_account()).to receive(:suspended?) { false }
              end

              describe "when the user was updated within less than the maximum number of inactive days" do
                before { self.user.update_attribute(:updated_at, Time.now - ($config.max_account_inactive_period.days - 1)) }

                it "return true" do
                  expect(user.current_email_account().active?).to be(true)
                end

              end

              describe "when the user was updated within more than the maximum number of inactive days" do
                before { self.user.update_attribute(:updated_at, Time.now - ($config.max_account_inactive_period.days + 1)) }

                it "return false" do
                  expect(user.current_email_account().active?).to be(false)
                end

              end

            end

          end

          describe ".suspended?" do
            let!(:new_gmail_account) { FactoryGirl.create(:gmail_account) }

            describe "when auth_errors_counter is less than $config.suspend_at_count" do
              before { new_gmail_account.update_attribute(:auth_errors_counter, $config.suspend_at_count - 1) }

              it "returns false" do
                expect(new_gmail_account.suspended?).to be(false)
              end

            end

            describe "when auth_errors_counter is greater than $config.suspend_at_count" do
              before { new_gmail_account.update_attribute(:auth_errors_counter, $config.suspend_at_count + 1) }

              it "returns true" do
                expect(new_gmail_account.suspended?).to be(true)
              end

            end

          end

          describe ".at_least_suspended?" do
            let!(:new_gmail_account) { FactoryGirl.create(:gmail_account) }

            describe "when auth_errors_counter is 0" do
              before { new_gmail_account.update_attribute(:auth_errors_counter, 0) }

              it "returns false" do
                expect(new_gmail_account.at_least_suspended?).to be(false)
              end

            end

            describe "when auth_errors_counter is not 0" do
              before { new_gmail_account.update_attribute(:auth_errors_counter, 1) }

              it "returns true" do
                expect(new_gmail_account.at_least_suspended?).to be(true)
              end

            end

          end

          describe ".already_in_sync?" do

            it "always returns false" do
              expect(gmail_account.already_in_sync?).to be(false)
            end

          end

        end

      end

      #########################################
      ### Setter Instance Method Unit Tests ###
      #########################################

      describe "Setter instance methods" do

        describe "set_job_uid!" do
          it "is pending spec implementation"
        end

      end

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe '.setup_push_channel' do
          it "is pending spec implementation"
        end

        describe '.suspend!' do
          it "is pending spec implementation"
        end

        describe '.delete_sync_job' do
          it "is pending spec implementation"
        end

        describe '.delete_o_auth2_token' do

          context "when the google_o_auth2_token exists" do

            it 'destroys the delete_o_auth2_token' do

              gmail_account.delete_o_auth2_token

              expect( gmail_account.google_o_auth2_token ).to be(nil)
            end

          end #__End of context "when the google_o_auth2_token exists"__

        end #__End of describe ".delete_o_auth2_token"__

        describe ".sync_account" do

          before(:each) {
            allow(gmail_account).to receive(:sync_email_folders)
            allow(gmail_account).to receive(:sync_email)

            gmail_account.sync_account
          }

          it 'synchronizes the labels' do
            expect(gmail_account).to have_received(:sync_email_folders)
          end

          it 'synchronizes the email' do
            expect(gmail_account).to have_received(:sync_email)
          end

          it 'updates #last_sync_at attribute' do
            expect(gmail_account.last_sync_at).to be_within(1).of Time.now
          end

        end #__End of describe ".sync_account"__

      end

    end

  end

end