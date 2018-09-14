require 'rails_helper'

RSpec.describe MimeTypeMapping, :type => :model do
  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
		  it { should have_db_column(:mime_type).of_type(:string)  }
		  it { should have_db_column(:usable_category_cd).of_type(:integer)  }
		  it { should have_db_column(:created_at).of_type(:datetime)  }
		  it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Uniqueness validations" do
      it { should validate_uniqueness_of(:mime_type) }
    end

  end

end
