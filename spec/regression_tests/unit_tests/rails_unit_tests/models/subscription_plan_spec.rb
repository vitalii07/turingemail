require 'rails_helper'

RSpec.describe SubscriptionPlan, :type => :model do
  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
		  it { should have_db_column(:amount).of_type(:integer)  }
		  it { should have_db_column(:interval).of_type(:string)  }
		  it { should have_db_column(:stripe_id).of_type(:string)  }
		  it { should have_db_column(:name).of_type(:string)  }
		  it { should have_db_column(:created_at).of_type(:datetime)  }
		  it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

  end

end
