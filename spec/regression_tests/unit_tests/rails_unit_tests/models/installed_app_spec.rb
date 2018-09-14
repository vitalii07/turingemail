# == Schema Information
#
# Table name: installed_apps
#
#  id                          :integer          not null, primary key
#  installed_app_subclass_id   :integer
#  installed_app_subclass_type :string(255)
#  user_id                     :integer
#  app_id                      :integer
#  permissions_email_headers   :boolean          default(FALSE)
#  permissions_email_content   :boolean          default(FALSE)
#  created_at                  :datetime
#  updated_at                  :datetime
#

require 'rails_helper'

RSpec.describe InstalledApp, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:app) { FactoryGirl.create(:app) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:installed_app_subclass_id).of_type(:integer)  }
      it { should have_db_column(:installed_app_subclass_type).of_type(:string)  }
      it { should have_db_column(:user_id).of_type(:integer)  }
      it { should have_db_column(:app_id).of_type(:integer)  }
      it { should have_db_column(:permissions_email_headers).of_type(:boolean)  }
      it { should have_db_column(:permissions_email_content).of_type(:boolean)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index([:installed_app_subclass_id, :installed_app_subclass_type]) }
      it { should have_db_index([:user_id, :app_id]).unique(true) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to(:installed_app_subclass).dependent(:destroy) }
      it { should belong_to :user }
      it { should belong_to :app }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:user) }
      it { should validate_presence_of(:app) }
    end

  end

end
