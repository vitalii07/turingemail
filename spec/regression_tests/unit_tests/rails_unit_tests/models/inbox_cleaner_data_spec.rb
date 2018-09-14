require 'rails_helper'

RSpec.describe InboxCleanerData, :type => :model do

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
  		it { should have_db_column(:is_read).of_type(:boolean)  }
		  it { should have_db_column(:is_calendar).of_type(:boolean)  }
		  it { should have_db_column(:is_list).of_type(:boolean)  }
		  it { should have_db_column(:is_auto_respond).of_type(:boolean)  }
		  it { should have_db_column(:created_at).of_type(:datetime)  }
		  it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Has one relationships" do
      it { should have_one(:email).dependent(:nullify) }
    end

  end
  
end
