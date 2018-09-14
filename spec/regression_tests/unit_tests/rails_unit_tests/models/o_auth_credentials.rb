require 'rails_helper'

RSpec.describe OAuthCredential, :type => :model do
  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:username).of_type(:string)  }
      it { should have_db_column(:salt).of_type(:text)  }
      it { should have_db_column(:initialization_vector).of_type(:text)  }
      it { should have_db_column(:encrypted_password).of_type(:text)  }
      it { should have_db_column(:api_id).of_type(:integer)  }
      it { should have_db_column(:api_type).of_type(:string)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

  end

end