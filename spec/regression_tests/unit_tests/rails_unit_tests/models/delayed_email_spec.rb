# == Schema Information
#
# Table name: delayed_emails
#
#  id                    :integer          not null, primary key
#  email_account_id      :integer
#  email_account_type    :string(255)
#  sidekiq_job_uid        :integer
#  uid                   :text
#  tos                   :text
#  ccs                   :text
#  bccs                  :text
#  subject               :text
#  html_part             :text
#  text_part             :text
#  email_in_reply_to_uid :text
#  tracking_enabled      :boolean
#  reminder_enabled           :boolean          default(FALSE)
#  reminder_time      :datetime
#  reminder_type      :text
#  created_at            :datetime
#  updated_at            :datetime
#  attachment_s3_keys    :text
#

require 'rails_helper'

RSpec.describe DelayedEmail, :type => :model do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }
  # let!(:delayed_job) { Delayed::Job.create(handler: "test handler", run_at: Time.now) }
  # let!(:sidekiq_job) {  } # TODO maybe refactor this to use only sidekiq_job_uid

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_account_id).of_type(:integer)  }
      it { should have_db_column(:email_account_type).of_type(:string)  }
      it { should have_db_column(:sidekiq_job_uid).of_type(:string)  }
      it { should have_db_column(:uid).of_type(:text)  }
      it { should have_db_column(:tos).of_type(:text)  }
      it { should have_db_column(:ccs).of_type(:text)  }
      it { should have_db_column(:bccs).of_type(:text)  }
      it { should have_db_column(:subject).of_type(:text)  }
      it { should have_db_column(:html_part).of_type(:text)  }
      it { should have_db_column(:text_part).of_type(:text)  }
      it { should have_db_column(:email_in_reply_to_uid).of_type(:text)  }
      it { should have_db_column(:tracking_enabled).of_type(:boolean)  }
      it { should have_db_column(:reminder_enabled).of_type(:boolean)  }
      it { should have_db_column(:reminder_time).of_type(:datetime)  }
      it { should have_db_column(:reminder_type).of_type(:text)  }
      it { should have_db_column(:attachment_s3_keys).of_type(:text)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index([:email_account_id, :email_account_type]) }
      it { should have_db_index(:sidekiq_job_uid) }
      it { should have_db_index(:uid).unique(true) }
    end

  end

  ################################
  ### Serialization Unit Tests ###
  ################################

  describe "Serialization" do
    it { should serialize(:tos) }
    it { should serialize(:ccs) }
    it { should serialize(:bccs) }
    it { should serialize(:attachment_s3_keys) }
  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :email_account }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Custom validations" do

      it "populates the uid before validation" do
        delayed_email = FactoryGirl.build(:delayed_email, email_account: email_account, uid: nil)

        expect(delayed_email.save).to be(true)
      end

    end

    describe "Presence validations" do
      it { should validate_presence_of(:email_account) }
    end

  end

  ###########################
  ### Callback Unit Tests ###
  ###########################

  describe "Callbacks" do

    describe "Before destroy callbacks" do

      it "calls update_counts method of the email_folder before destroy" do
        delayed_email = FactoryGirl.create(:delayed_email, email_account: email_account)
        job = make_sidekiq_job(delayed_email)
        delayed_email.destroy
        expect(find_sidekiq_job(job)).to be(nil)
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

        describe ".sidekiq_job" do

          let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account) }

          it 'returns the delayed job' do
            job = make_sidekiq_job(delayed_email)
            expect(delayed_email.sidekiq_job_uid).to eq(job)
          end

        end #__End of describe ".sidekiq_job"__

        describe ".send_at" do

          context 'when the sidekiq_job is nil' do
            let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account, sidekiq_job_uid: nil) }

            it "returns nil" do
              expect(delayed_email.send_at).to be(nil)
            end

          end

          context 'when the sidekiq_job is not nil' do
            it "returns the running time of the sidekiq_job" do
              delayed_email =  FactoryGirl.create(:delayed_email, email_account: email_account)
              job = make_sidekiq_job(delayed_email)
              expect(delayed_email.sidekiq_job_uid).to eq job
              # TODO need run with Sidekiq::Testing.inline! and mocked SMTP
              # expect(delayed_email.send_at).to eq 3.days.from_now # some issue with test env and enq is blank eq(delayed_email.sidekiq_job.enqueued_at)
            end

          end

        end #__End of describe ".send_at"__

        describe ".sidekiq_status" do
          let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account) }
          before { make_sidekiq_job(delayed_email) }

          it "return the sidekiq status for the job uid" do
            expect(delayed_email.sidekiq_status).to eq(Sidekiq::Status::get_all(delayed_email.sidekiq_job_uid))
          end

        end

        #################################################
        ### Boolean Getter Instance Method Unit Tests ###
        #################################################

        describe "Boolean getter instance methods" do

          describe ".has_been_scheduled?" do

            describe "when the delayed email's sidekiq_job_uid is set" do
              let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account) }
              before { make_sidekiq_job(delayed_email) }

              it "return true" do
                expect(delayed_email.has_been_scheduled?).to be(true)
              end

            end

            describe "when the delayed email's sidekiq_job_uid is nill" do
              let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account, sidekiq_job_uid: nil) }

              it "return false" do
                expect(delayed_email.has_been_scheduled?).to be(false)
              end

            end

          end

        end

      end

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".send_and_destroy" do

          let!(:delayed_email) { FactoryGirl.create(:delayed_email, email_account: email_account) }
          let(:email_params){ [delayed_email.tos, [], [], delayed_email.subject, delayed_email.html_part, delayed_email.text_part, nil, false,
                               nil, nil, nil] }

          it 'sends email to the email account' do
            expect {
              job = make_sidekiq_job(delayed_email)
              expect(job).not_to be blank?
            }.to change(EmailSenderJob.jobs, :size).by 1
            expect(EmailSenderJob).to have_enqueued_job(email_account.id, delayed_email.id, email_params)
          end

          it 'is destroyed' do
            job = delayed_email.send_and_destroy_at(15.minutes.from_now)
            Timecop.freeze(16.minutes.from_now) do
              expect(EmailSenderJob).to have_enqueued_job(email_account.id, delayed_email.id, email_params)
              #expect(delayed_email).to have_received(:destroy!)
              expect(delayed_email.sidekiq_job).to eq nil
            end

          end

        end #__End of describe ".send_and_destroy"__

        describe ".reschedule_job" do
          it "is pending spec implementation"
        end #__End of describe ".reschedule_job"__

      end

    end

  end

  ####################
  ### Test Helpers ###
  ####################

  def make_sidekiq_job(delayed_email)
    delayed_email.send_and_destroy_at(3.days.from_now)
  end

  def find_sidekiq_job(sidekiq_job)
    Sidekiq::ScheduledSet.new.find_job(sidekiq_job)
  end

end
