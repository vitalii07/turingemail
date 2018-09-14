# == Schema Information
#
# Table name: email_recipients
#
#  id             :integer          not null, primary key
#  email_id       :integer
#  person_id      :integer
#  recipient_type :integer
#  created_at     :datetime
#  updated_at     :datetime
#

require 'rails_helper'

RSpec.describe EmailRecipient, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }
  let!(:person) { FactoryGirl.create(:person, :email_account => email.email_account) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_id).of_type(:integer)  }
      it { should have_db_column(:person_id).of_type(:integer)  }
      it { should have_db_column(:recipient_type).of_type(:integer)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }  
    end

    describe "Indexes" do
      it { should have_db_index([:email_id, :person_id, :recipient_type]).unique(true) }
      it { should have_db_index(:email_id) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :email }
      it { should belong_to :person }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:email_id) }
      it { should validate_presence_of(:person) }
      it { should validate_presence_of(:recipient_type) }
    end

  end

  #######################
  ### Enum Unit Tests ###
  #######################

  describe "Enums" do

    it "defines the recipient_type enum" do
      should define_enum_for(:recipient_type).
        with({ :to => 0, :cc => 1, :bcc => 2 })
    end

  end

end
