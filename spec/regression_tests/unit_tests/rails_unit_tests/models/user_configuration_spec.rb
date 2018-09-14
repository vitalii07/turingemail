# == Schema Information
#
# Table name: user_configurations
#
#  id                         :integer          not null, primary key
#  user_id                    :integer
#  keyboard_shortcuts_enabled :boolean          default(TRUE)
#  automatic_inbox_cleaner_enabled              :boolean          default(TRUE)
#  split_pane_mode            :text             default("horizontal")
#  developer_enabled          :boolean          default(FALSE)
#  skin_id                    :integer
#  created_at                 :datetime
#  updated_at                 :datetime
#  email_list_view_row_height :integer
#  auto_cleaner_enabled       :boolean          default(FALSE)
#  inbox_tabs_enabled         :boolean
#  email_signature_id         :integer
#

require 'rails_helper'

RSpec.describe UserConfiguration, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }
  before { user.user_configuration.destroy }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:user_id).of_type(:integer)  }
      it { should have_db_column(:keyboard_shortcuts_enabled).of_type(:boolean)  }
      it { should have_db_column(:automatic_inbox_cleaner_enabled).of_type(:boolean)  }
      it { should have_db_column(:developer_enabled).of_type(:boolean)  }
      it { should have_db_column(:auto_cleaner_enabled).of_type(:boolean)  }
      it { should have_db_column(:inbox_tabs_enabled).of_type(:boolean)  }
      it { should have_db_column(:context_sidebar_enabled).of_type(:boolean)  }
      it { should have_db_column(:split_pane_mode).of_type(:text)  }
      it { should have_db_column(:email_list_view_row_height).of_type(:integer)  }
      it { should have_db_column(:email_signature_id).of_type(:integer)  }
      it { should have_db_column(:skin_id).of_type(:integer)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index(:email_signature_id) }
      it { should have_db_index(:skin_id) }
      it { should have_db_index(:user_id).unique(true) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :user }
      it { should belong_to :skin }
      it { should belong_to :email_signature }
    end

  end

  #######################
  ### Enum Unit Tests ###
  #######################

  describe "Enums" do

    it "defines the split_pane_mode enum" do
      should define_enum_for(:split_pane_mode).
        with({:off => 'off', :horizontal => 'horizontal', :vertical => 'vertical'})
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:user) }
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
      
        describe ".restore_default_configurations" do
          it "is pending spec implementation"
        end

      end

    end

  end

end
