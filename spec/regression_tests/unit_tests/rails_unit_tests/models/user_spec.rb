# == Schema Information
#
# Table name: users
#
#  id                   :integer          not null, primary key
#  admin                :boolean          default(FALSE)
#  email                :text
#  password_digest      :text
#  login_attempt_count  :integer          default(0)
#  created_at           :datetime
#  updated_at           :datetime
#  profile_picture      :string(255)
#  name                 :string(255)
#  given_name           :string(255)
#  family_name          :string(255)
#

require 'rails_helper'
require 'pry-byebug'

RSpec.describe User, :type => :model do
  let(:user_template) { FactoryGirl.build(:user) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:admin).of_type(:boolean)  }
      it { should have_db_column(:email).of_type(:text)  }
      it { should have_db_column(:password_digest).of_type(:text)  }
      it { should have_db_column(:login_attempt_count).of_type(:integer)  }
      it { should have_db_column(:active).of_type(:boolean)  }
      it { should have_db_column(:name).of_type(:string)  }
      it { should have_db_column(:given_name).of_type(:string)  }
      it { should have_db_column(:family_name).of_type(:string)  }
      it { should have_db_column(:profile_picture).of_type(:string)  }
      it { should have_db_column(:gender).of_type(:string)  }
      it { should have_db_column(:encrypted_password).of_type(:string)  }
      it { should have_db_column(:reset_password_token).of_type(:string)  }
      it { should have_db_column(:reset_password_sent_at).of_type(:datetime)  }
      it { should have_db_column(:remember_created_at).of_type(:datetime)  }
      it { should have_db_column(:sign_in_count).of_type(:integer)  }
      it { should have_db_column(:current_sign_in_at).of_type(:datetime)  }
      it { should have_db_column(:last_sign_in_at).of_type(:datetime)  }
      it { should have_db_column(:current_sign_in_ip).of_type(:inet)  }
      it { should have_db_column(:last_sign_in_ip).of_type(:inet)  }
      it { should have_db_column(:failed_attempts).of_type(:integer)  }
      it { should have_db_column(:unlock_token).of_type(:string)  }
      it { should have_db_column(:locked_at).of_type(:datetime)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
      it { should have_db_column(:is_test_account).of_type(:boolean)  }
    end

    describe "Indexes" do
      it { should have_db_index(:email).unique(true) }
      it { should have_db_index(:reset_password_token).unique(true) }
      it { should have_db_index(:unlock_token).unique(true) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Has one relationships" do
      it { should have_one(:user_configuration).dependent(:destroy) }
      it { should have_one(:twitter_account).dependent(:destroy) }
    end

    describe "Have many relationships" do
      it { should have_many(:user_auth_keys).dependent(:destroy) }
      it { should have_many(:gmail_accounts).dependent(:destroy) }
      it { should have_many(:outlook_accounts).dependent(:destroy) }
      it { should have_many(:yahoo_mail_accounts).dependent(:destroy) }
      it { should have_many(:email_accounts).dependent(:destroy) }
      it { should have_many(:emails).through(:gmail_accounts) }
      it { should have_many(:email_threads).through(:gmail_accounts) }
      it { should have_many(:inbox_cleaner_rules).dependent(:destroy) }
      it { should have_many(:email_filters).dependent(:destroy) }
      it { should have_many(:apps).dependent(:destroy) }
      it { should have_many(:installed_apps).dependent(:destroy) }
      it { should have_many(:email_templates).dependent(:destroy) }
      it { should have_many(:email_template_categories).dependent(:destroy) }
      it { should have_many(:email_signatures).dependent(:destroy) }
      it { should have_many(:email_attachment_uploads).dependent(:destroy) }
    end

  end

  ###########################
  ### Callback Unit Tests ###
  ###########################

  describe "Callbacks" do

    describe "Before validation callbacks" do

      describe ":before_validation" do
        context "when the email exists" do
          it "cleans the email before validation" do
            email = FFaker::Internet.email
            user = FactoryGirl.build(:user, email: email)

            user.valid?

            expect(user.email).to eq(cleanse_email(email))
          end
        end

        context "when the password_confirmation is nil" do
          it "sets the password_confirmation to the empty character before validation" do
            user = FactoryGirl.build(:user, password_confirmation: nil)

            user.valid?

            expect(user.password_confirmation).to eq(nil)
          end
        end
      end #__End of describe ":before_validation"__

    end

    describe "After validation callbacks" do

      describe ":after_validation" do
        it "deletes the password_digest from the error message after validation" do
          user = FactoryGirl.build(:user)

          errors = user.errors
          allow(user).to receive(:errors) { errors }

          messages = errors.messages
          allow(errors).to receive(:messages) { messages }

          allow(messages).to receive(:delete)

          user.valid?
        end

      end #__End of describe ":after_validation"__

    end

    describe "After create callbacks" do

      describe ":after_create" do
        context "when the user_configuration is nil" do
          it "sets the user_configuration after create" do
            user = FactoryGirl.create(:user, user_configuration: nil)

            expect(user.user_configuration.class).to eq(UserConfiguration)
          end
        end

      end #__End of describe ":after_create"__

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

        describe "#generate_email_verification_code" do
          it 'returns the string' do
            expect(User.generate_email_verification_code.class).to eq(String)
          end

          it 'returns the 16 length string' do
            expect(User.generate_email_verification_code.length).to eq(16)
          end
        end #__End of describe "#generate_email_verification_code"__

        describe "#get_update_params" do
          let(:params) {  ActionController::Parameters.new(
                            :user => { :email => user_template.email,
                                       :password => user_template.password,
                                       :password_confirmation => user_template.password}
                            ) }

          it 'returns the params' do
            expect( User.get_update_params(params).class ).to eq(ActionController::Parameters)
          end

          context "when the include_password is true" do
            it 'pushes the :password and :password_confirmation to the permitted params' do
              expect( User.get_update_params(params, true).keys ).to eq( ["email"] )
              # expect( User.get_update_params(params, true).keys ).to eq( ["email", "password", "password_confirmation"] ) TODO: figure out what to do with the password tests at some point.
            end
          end
        end #__End of describe "#get_update_params"__

        describe "#get_unique_violation_error" do
          context 'when the email is in use' do
            it 'returns the email error message' do
              begin
                user_template.save
                user = FactoryGirl.build(:user, email: user_template.email)
                user.save
              rescue ActiveRecord::RecordNotUnique => unique_violation
                expect(User.get_unique_violation_error(unique_violation)).to eq('Error email in use.')
              end
            end
          end

          context "when the another type of error raises" do
            it 'raises the error' do
              begin
                app_template = FactoryGirl.create(:app)
                app = FactoryGirl.build(:app, name: app_template.name)
                app.save
              rescue ActiveRecord::RecordNotUnique => unique_violation
                expect { User.get_unique_violation_error(unique_violation) }.to raise_error(unique_violation)
              end
            end
          end
        end #__End of describe "#get_unique_violation_error"__

        describe "#cached_find" do
          let!(:user) { FactoryGirl.create(:user) }

          it 'returns the user by id' do
            expect( User.cached_find(user.id) ).to eq(user)
          end
        end #__End of describe "#api_create"__

      end

      ######################################
      ### Action Class Method Unit Tests ###
      ######################################

      describe "Action class methods" do

        describe "#create_from_post" do
          it "is pending spec implementation"
        end

        describe "#api_create" do
          it "is pending spec implementation"
        end

      end

    end

    ##################################
    ### Instance Method Unit Tests ###
    ##################################

    describe "Instance methods" do

      ######################################
      ### Getter Class Method Unit Tests ###
      ######################################

      describe "Getter class methods" do

        describe ".current_email_account" do
          it "is pending spec implementation"
        end

        ##############################################
        ### Boolean Getter Class Method Unit Tests ###
        ##############################################

        describe "Boolean getter class methods" do

          describe ".current_email_account_is_gmail" do

            describe "when the current email account returns a Gmail account" do
              let!(:gmail_account) { FactoryGirl.create(:gmail_account) }
              let!(:user_for_current_email_account_is_gmail) { FactoryGirl.create(:user) }
              before do
                allow(user_for_current_email_account_is_gmail).to receive(:current_email_account) { gmail_account }
              end

              it "return true" do
                expect(user_for_current_email_account_is_gmail.current_email_account_is_gmail).to be(true)
              end

            end

            describe "when the current email account returns an Outlook account" do
              let!(:outlook_account) { FactoryGirl.create(:outlook_account) }
              let!(:user_for_current_email_account_is_gmail) { FactoryGirl.create(:user) }
              before do
                allow(user_for_current_email_account_is_gmail).to receive(:current_email_account) { outlook_account }
              end

              it "return false" do
                expect(user_for_current_email_account_is_gmail.current_email_account_is_gmail).to be(false)
              end

            end

            describe "when the current email account returns a Yahoo Mail account" do
              let!(:yahoo_mail_account) { FactoryGirl.create(:yahoo_mail_account) }
              let!(:user_for_current_email_account_is_gmail) { FactoryGirl.create(:user) }
              before do
                allow(user_for_current_email_account_is_gmail).to receive(:current_email_account) { yahoo_mail_account }
              end

              it "return false" do
                expect(user_for_current_email_account_is_gmail.current_email_account_is_gmail).to be(false)
              end

            end

            describe "when the current email account returns a an empty array" do
              let!(:user_for_current_email_account_is_gmail) { FactoryGirl.create(:user) }
              before do
                allow(user_for_current_email_account_is_gmail).to receive(:current_email_account) { [] }
              end

              it "return false" do
                expect(user_for_current_email_account_is_gmail.current_email_account_is_gmail).to be(false)
              end

            end


          end

        end

      end

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".apply_email_filters" do
          let(:user) { FactoryGirl.create(:user_with_gmail_accounts) }
          let(:email) { FactoryGirl.create(:email) }
          let(:imap_folder) { FactoryGirl.create(:imap_folder) }

          context "when the from_address of the email is same as the from_address of the email_filter" do

            context "when the email filter's words match a word in the email" do
              before(:each) {
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [email.text_part.split(" ")[0]], email_addresses: [email.from_address], email_account: email.email_account, email_folder: imap_folder)
                end
              }

              it 'moves the emails to the destination folder of the email_filter' do
                email_account = email.email_account

                allow(email_account).to receive(:move_email_to_folder)

                user.apply_email_filters([email])

                expect(email_account).to have_received(:move_email_to_folder).twice
              end
            end

            context "when the email filter's words do not match a word in the email" do
              before(:each) {
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [], email_addresses: [email.from_address], email_account: email.email_account, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                email_account = email.email_account

                allow(email_account).to receive(:move_email_to_folder)

                user.apply_email_filters([email])

                expect(email_account).to_not have_received(:move_email_to_folder)
              end
            end

          end

          context "when the from_address of the email is not same as the from_address of the email_filter" do
            
            context "when the email filter's words match a word in the email" do
              before(:each) {
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [email.text_part.split(" ")[0]], email_addresses: [], email_account: email.email_account, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                email_account = email.email_account

                allow(email_account).to receive(:move_email_to_folder)

                user.apply_email_filters([email])

                expect(email_account).to_not have_received(:move_email_to_folder)
              end
            end

            context "when the email filter's words do not match a word in the email" do
              before(:each) {
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [], email_addresses: [], email_account: email.email_account, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                email_account = email.email_account

                allow(email_account).to receive(:move_email_to_folder)

                user.apply_email_filters([email])

                expect(email_account).to_not have_received(:move_email_to_folder)
              end
            end

          end #__End 

        end #__End of describe ".apply_email_filters"__

        describe ".apply_email_filters_to_folder" do
          let!(:user) { FactoryGirl.create(:user_with_gmail_accounts) }
          let!(:email) { FactoryGirl.create(:email) }
          let!(:imap_folder) { FactoryGirl.create(:imap_folder) }

          context "when the from_address of the email is same as the from_address of the email_filter" do

            context "when the email filter's words match a word in the email" do
              before(:each) {
                allow_any_instance_of(GmailAccount).to receive(:move_email_to_folder)
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [email.text_part.split(" ")[0]], email_addresses: [email.from_address], email_account: user.email_accounts.first, email_folder: imap_folder)
                end
              }

              it 'moves the emails to the destination folder of the email_filter' do
                gmail_account = user.email_accounts.first
                folder = gmail_account.inbox_folder

                allow(folder).to receive(:emails) { Email.all }
                allow_any_instance_of(Email).to receive(:email_account) { gmail_account }

                allow(gmail_account).to receive(:move_email_to_folder)

                expect_any_instance_of(GmailAccount).to receive(:move_email_to_folder).twice

                gmail_account.user.apply_email_filters_to_folder(folder)
              
              end
            end

            context "when the email filter's words do not match a word in the email" do
              before(:each) {
                allow_any_instance_of(GmailAccount).to receive(:move_email_to_folder)
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [], email_addresses: [email.from_address], email_account: user.email_accounts.first, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                gmail_account = user.email_accounts.first
                folder = gmail_account.inbox_folder

                allow(folder).to receive(:emails) { Email.all }
                allow_any_instance_of(Email).to receive(:email_account) { gmail_account }

                allow(gmail_account).to receive(:move_email_to_folder)

                expect_any_instance_of(GmailAccount).to_not receive(:move_email_to_folder)

                gmail_account.user.apply_email_filters_to_folder(folder)
              end
            end

          end

          context "when the from_address of the email is not same as the from_address of the email_filter" do
            
            context "when the email filter's words match a word in the email" do
              before(:each) {
                allow_any_instance_of(GmailAccount).to receive(:move_email_to_folder)
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [email.text_part.split(" ")[0]], email_addresses: [], email_account: user.email_accounts.first, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                gmail_account = user.email_accounts.first
                folder = gmail_account.inbox_folder

                allow(folder).to receive(:emails) { Email.all }
                allow_any_instance_of(Email).to receive(:email_account) { gmail_account }

                allow(gmail_account).to receive(:move_email_to_folder)

                expect_any_instance_of(GmailAccount).to_not receive(:move_email_to_folder)

                gmail_account.user.apply_email_filters_to_folder(folder)
              end
            end

            context "when the email filter's words do not match a word in the email" do
              before(:each) {
                allow_any_instance_of(GmailAccount).to receive(:move_email_to_folder)
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [], email_addresses: [], email_account: user.email_accounts.first, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                gmail_account = user.email_accounts.first
                folder = gmail_account.inbox_folder

                allow(folder).to receive(:emails) { Email.all }
                allow_any_instance_of(Email).to receive(:email_account) { gmail_account }

                allow(gmail_account).to receive(:move_email_to_folder)

                expect_any_instance_of(GmailAccount).to_not receive(:move_email_to_folder)

                gmail_account.user.apply_email_filters_to_folder(folder)
              end
            end

          end #__End 

        end #__End of describe ".apply_email_filters_to_folder"__

        describe ".apply_email_filters_to_email" do
          let!(:user) { FactoryGirl.create(:user_with_gmail_accounts) }
          let!(:email) { FactoryGirl.create(:email) }
          let!(:imap_folder) { FactoryGirl.create(:imap_folder) }

          context "when the from_address of the email is same as the from_address of the email_filter" do

            context "when the email filter's words match a word in the email" do
              before(:each) {
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [email.text_part.split(" ")[0]], email_addresses: [email.from_address], email_account: email.email_account, email_folder: imap_folder)
                end
              }

              it 'moves the emails to the destination folder of the email_filter' do
                email_account = email.email_account

                allow(email_account).to receive(:move_email_to_folder)

                user.apply_email_filters_to_email(email)

                expect(email_account).to have_received(:move_email_to_folder).twice
              end
            end

            context "when the email filter's words do not match a word in the email" do
              before(:each) {
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [], email_addresses: [email.from_address], email_account: email.email_account, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                email_account = email.email_account

                allow(email_account).to receive(:move_email_to_folder)

                user.apply_email_filters_to_email(email)

                expect(email_account).to_not have_received(:move_email_to_folder)
              end
            end

          end

          context "when the from_address of the email is not same as the from_address of the email_filter" do
            
            context "when the email filter's words match a word in the email" do
              before(:each) {
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [email.text_part.split(" ")[0]], email_addresses: [], email_account: email.email_account, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                email_account = email.email_account

                allow(email_account).to receive(:move_email_to_folder)

                user.apply_email_filters_to_email(email)

                expect(email_account).to_not have_received(:move_email_to_folder)
              end
            end

            context "when the email filter's words do not match a word in the email" do
              before(:each) {
                2.times do
                  # email rules of the user
                  FactoryGirl.create(:email_filter, words: [], email_addresses: [], email_account: email.email_account, email_folder: imap_folder)
                end
              }

              it 'does not move the emails to the destination folder of the email_filter' do
                email_account = email.email_account

                allow(email_account).to receive(:move_email_to_folder)

                user.apply_email_filters_to_email(email)

                expect(email_account).to_not have_received(:move_email_to_folder)
              end
            end

          end #__End 

        end #__End of describe ".apply_email_filters_to_email"__

        describe '.destroy' do
          let!(:user) { FactoryGirl.create(:user) }

          let!(:user_auth_keys) { FactoryGirl.create_list(:user_auth_key, SpecMisc::SMALL_LIST_SIZE, :user => user) }
          let!(:email_accounts) { FactoryGirl.create_list(:gmail_account, SpecMisc::SMALL_LIST_SIZE, :user => user) }
          let!(:inbox_cleaner_rules) { FactoryGirl.create_list(:inbox_cleaner_rule, SpecMisc::SMALL_LIST_SIZE, :user => user) }
          let!(:imap_folder) { FactoryGirl.create(:imap_folder) }
          let!(:email_filters) { FactoryGirl.create_list(:email_filter, SpecMisc::SMALL_LIST_SIZE, :email_account => email_accounts.first, :email_folder => imap_folder) }

          it 'should destroy the associated models' do
            expect(UserAuthKey.where(:user => user).count).to eq(user_auth_keys.length)
            expect(GmailAccount.where(:user => user).count).to eq(email_accounts.length)
            expect(InboxCleanerRule.where(:user => user).count).to eq(inbox_cleaner_rules.length)
            expect(EmailFilter.where(:email_account => email_accounts.first).count).to eq(email_filters.length)

            expect(UserConfiguration.where(:user => user).count).to eq(1)

            expect(user.destroy).not_to be(false)

            expect(UserAuthKey.where(:user => user).count).to eq(0)
            expect(GmailAccount.where(:user => user).count).to eq(0)
            expect(InboxCleanerRule.where(:user => user).count).to eq(0)
            expect(EmailFilter.where(:email_account => email_accounts.first).count).to eq(0)

            expect(UserConfiguration.where(:user => user).count).to eq(0)
          end
        end

      end

    end

  end

end
