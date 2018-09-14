require 'rails_helper'

RSpec.describe InboxCleanerReport, :type => :model do
  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:read_emails).of_type(:integer)  }
      it { should have_db_column(:list_emails).of_type(:integer)  }
      it { should have_db_column(:calendar_emails).of_type(:integer)  }
      it { should have_db_column(:auto_respond_emails).of_type(:integer)  }
      it { should have_db_column(:progress).of_type(:integer)  }
      it { should have_db_column(:email_account_id).of_type(:integer)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index(:email_account_id) }
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

  #########################
  ### Method Unit Tests ###
  #########################

  describe "Methods" do

    ##################################
    ### Instance Method Unit Tests ###
    ##################################

    describe "Instance methods" do

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".run" do
          it "is pending spec implementation"
        end

      end

    end

  end

end
