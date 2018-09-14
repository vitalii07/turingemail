# == Schema Information
#
# Table name: email_signatures
#
#  id         :integer          not null, primary key
#  user_id    :integer
#  uid        :text
#  name       :text
#  text       :text
#  html       :text
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe EmailSignature, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:user_id).of_type(:integer)  }
      it { should have_db_column(:uid).of_type(:text)  }
      it { should have_db_column(:name).of_type(:text)  }
      it { should have_db_column(:text).of_type(:text)  }
      it { should have_db_column(:html).of_type(:text)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }  
    end

    describe "Indexes" do
      it { should have_db_index(:uid).unique(true) }
      it { should have_db_index([:user_id, :name]).unique(true) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :user }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Custom validations" do

      it "populates the uid before validation" do
        email_signature = FactoryGirl.build(:email_signature, user: user, uid: nil)
         
        expect(email_signature.save).to be(true)
      end

    end

    describe "Presence validations" do
      it { should validate_presence_of(:user) }
      it { should validate_presence_of(:name) }
    end

  end

end
