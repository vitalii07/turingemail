# == Schema Information
#
# Table name: email_tracker_recipients
#
#  id               :integer          not null, primary key
#  email_tracker_id :integer
#  email_id         :integer
#  uid              :text
#  email_address    :text
#  created_at       :datetime
#  updated_at       :datetime
#

require 'rails_helper'

RSpec.describe EmailTrackerRecipient, :type => :model do
  let!(:email_tracker) { FactoryGirl.create(:email_tracker) }
  let!(:email) { FactoryGirl.create(:email) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_tracker_id).of_type(:integer)  }
      it { should have_db_column(:email_id).of_type(:integer)  }
      it { should have_db_column(:uid).of_type(:text)  }
      it { should have_db_column(:email_address).of_type(:text)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index(:email_id) }
      it { should have_db_index(:email_tracker_id) }
      it { should have_db_index(:uid).unique(true) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :email_tracker }
      it { should belong_to :email }
    end

    describe "Have many relationships" do
      it { should have_many(:email_tracker_views).dependent(:destroy) }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Custom validations" do

      it "populates the uid before validation" do
        email_tracker_recipient = FactoryGirl.create(:email_tracker_recipient, uid: nil)
        email_tracker_recipient.valid?
        expect(email_tracker_recipient.uid.nil?).to be(false)
      end

    end

    describe "Presence validations" do
      it { should validate_presence_of(:email_tracker) }
      it { should validate_presence_of(:email_address) }
    end

  end

end
