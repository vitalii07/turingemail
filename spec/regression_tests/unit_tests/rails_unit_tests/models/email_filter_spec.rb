# == Schema Information
#
# Table name: email_filters
#
#  id                      :integer          not null, primary key
#  user_id                 :integer
#  uid                     :text
#  from_address            :text
#  to_address              :text
#  subject                 :text
#  list_id                 :text
#  destination_folder_name :text
#  created_at              :datetime
#  updated_at              :datetime
#

require 'rails_helper'

RSpec.describe EmailFilter, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_account_id).of_type(:integer)  }
      it { should have_db_column(:email_account_type).of_type(:string)  }
      it { should have_db_column(:email_folder_id).of_type(:integer)  }
      it { should have_db_column(:email_folder_type).of_type(:string)  }
      it { should have_db_column(:email_addresses).of_type(:string)  }
      it { should have_db_column(:words).of_type(:string)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }  
    end

    describe "Indexes" do
      it { should have_db_index([:email_account_type, :email_account_id]) }
      it { should have_db_index([:email_folder_type, :email_folder_id]) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :email_account }
      it { should belong_to :email_folder }
    end

  end

end
