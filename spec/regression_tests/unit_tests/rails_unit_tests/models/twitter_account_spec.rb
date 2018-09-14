require "rails_helper"

RSpec.describe TwitterAccount, type: :model do
  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do
    describe "Columns" do
      it { should have_db_column(:user_id).of_type(:integer)  }
      it { should have_db_column(:access_token).of_type(:string)  }
      it { should have_db_column(:access_token_secret).of_type(:string)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index(:user_id) }
    end
  end

  ###############################
  ### Relationship Unit Tests ###
  ###############################

  describe "Relationships" do
    describe "Belongs to relationships" do
      it { should belong_to :user }
    end
  end
end
