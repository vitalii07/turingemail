# == Schema Information
#
# Table name: sync_failed_emails
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string(255)
#  email_uid          :text
#  result             :text
#  exception          :text
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

RSpec.describe SyncFailedEmail, :type => :model do
  let!(:email_account) { FactoryGirl.create(:gmail_account) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_account_id).of_type(:integer)  }
      it { should have_db_column(:email_account_type).of_type(:string)  }
      it { should have_db_column(:email_uid).of_type(:text)  }
      it { should have_db_column(:result).of_type(:text)  }
      it { should have_db_column(:exception).of_type(:text)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index([:email_account_id, :email_account_type, :email_uid]).unique(true) }
    end

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

    describe "Presence validations" do
      it { should validate_presence_of(:email_account) }
      it { should validate_presence_of(:email_uid) }
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
      ### Action Class Method Unit Tests ###
      ######################################

      describe "Action class methods" do

        describe "#create_retry" do
          let(:email_uid) { SecureRandom.uuid() }
          it 'creates new sync failed email instance' do
            
            expect(SyncFailedEmail.create_retry(email_account, email_uid).class).to eq(SyncFailedEmail)
          end

        end #__End of describe "#create_retry"__

      end

    end

  end

end
