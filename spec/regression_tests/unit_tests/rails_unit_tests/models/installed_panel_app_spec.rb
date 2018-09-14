# == Schema Information
#
# Table name: installed_panel_apps
#
#  id         :integer          not null, primary key
#  panel      :text             default("right")
#  position   :integer          default(0)
#  created_at :datetime
#  updated_at :datetime
#

require 'rails_helper'

RSpec.describe InstalledPanelApp, :type => :model do
  let!(:installed_app) { FactoryGirl.create(:installed_app) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:panel).of_type(:text)  }
      it { should have_db_column(:position).of_type(:integer)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Has one relationships" do
      it { should have_one(:installed_app) }
    end

  end

  #######################
  ### Enum Unit Tests ###
  #######################

  describe "Enums" do

    it "defines the panel enum" do
      should define_enum_for(:panel).
        with({:right => 'right'})
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:installed_app) }
      it { should validate_presence_of(:panel) }
      it { should validate_presence_of(:position) }
    end

  end

end
