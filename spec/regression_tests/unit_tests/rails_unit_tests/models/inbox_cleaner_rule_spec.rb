# == Schema Information
#
# Table name: inbox_cleaner_rules
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uid          :text
#  from_address :text
#  to_address   :text
#  subject      :text
#  list_id      :text
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

RSpec.describe InboxCleanerRule, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:user_id).of_type(:integer)  }
      it { should have_db_column(:uid).of_type(:text)  }
      it { should have_db_column(:from_address).of_type(:text)  }
      it { should have_db_column(:to_address).of_type(:text)  }
      it { should have_db_column(:subject).of_type(:text)  }
      it { should have_db_column(:list_id).of_type(:text)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index([:from_address, :to_address, :subject, :list_id]).unique(true) }
      it { should have_db_index(:uid).unique(true) }
      it { should have_db_index(:user_id) }
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
        inbox_cleaner_rule = FactoryGirl.build(:inbox_cleaner_rule, user: user, uid: nil)
        inbox_cleaner_rule.valid?
        expect(inbox_cleaner_rule.uid.nil?).to be(false)
      end

      it "should add an error if the from_address, to_address, subject and list_id is blank" do
        inbox_cleaner_rule = FactoryGirl.build(:inbox_cleaner_rule, user: user, from_address: nil, to_address: nil, subject: nil, list_id: nil)
        inbox_cleaner_rule.valid?
        inbox_cleaner_rule.errors[:base].should eq(['This inbox cleaner rule is invalid because no criteria was specified.'])
      end

    end

    describe "Presence validations" do
      it { should validate_presence_of(:user) }
    end

  end

end
