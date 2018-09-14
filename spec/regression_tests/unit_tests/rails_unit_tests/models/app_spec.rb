# == Schema Information
#
# Table name: apps
#
#  id           :integer          not null, primary key
#  user_id      :integer
#  uid          :text
#  name         :text
#  description  :text
#  app_type     :text
#  callback_url :text
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

RSpec.describe App, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:user_id).of_type(:integer) }
      it { should have_db_column(:uid).of_type(:text) }
      it { should have_db_column(:name).of_type(:text) }
      it { should have_db_column(:description).of_type(:text) }
      it { should have_db_column(:app_type).of_type(:text) }
      it { should have_db_column(:callback_url).of_type(:text) }
      it { should have_db_column(:created_at).of_type(:datetime) }
      it { should have_db_column(:updated_at).of_type(:datetime) }
    end

    describe "Indexes" do
      it { should have_db_index(:name).unique(true) }
      it { should have_db_index(:uid).unique(true) }
      it { should have_db_index(:user_id) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :user }
    end

    describe "Have many relationships" do
      it { should have_many(:installed_apps).dependent(:destroy) }
    end

  end

  #######################
  ### Enum Unit Tests ###
  #######################

  describe "Enums" do

    it "defines the app_type enum" do
      should define_enum_for(:app_type).
        with({ :panel => 'panel' })
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Custom validations" do

      it "populates the uid before validation" do
        app = FactoryGirl.build(:app, uid: nil)
         
        expect(app.save).to be(true)
      end

    end

    describe "Presence validations" do
      it { should validate_presence_of(:user) }
      it { should validate_presence_of(:name) }
      it { should validate_presence_of(:description) }
      it { should validate_presence_of(:app_type) }
      it { should validate_presence_of(:callback_url) }
    end

  end

end
