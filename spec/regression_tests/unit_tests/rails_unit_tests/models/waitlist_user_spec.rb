require 'rails_helper'

RSpec.describe WaitlistUser, :type => :model do
  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
		  it { should have_db_column(:email).of_type(:string)  }
		  it { should have_db_column(:collection_type).of_type(:string)  }
		  it { should have_db_column(:created_at).of_type(:datetime)  }
		  it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:collection_type) }
    end

    describe "Uniqueness validations" do
      it { should validate_uniqueness_of(:email) }
    end

  end

end
