# == Schema Information
#
# Table name: email_folder_mappings
#
#  id                       :integer          not null, primary key
#  email_id                 :integer
#  email_folder_id          :integer
#  email_folder_type        :string(255)
#  email_thread_id          :integer
#  folder_email_date        :datetime
#  folder_email_draft_id    :text
#  folder_email_thread_date :datetime
#  created_at               :datetime
#  updated_at               :datetime
#

require 'rails_helper'

RSpec.describe EmailFolderMapping, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }
  let!(:email_thread) { FactoryGirl.create(:email_thread) }
  let!(:email_folder) { FactoryGirl.create(:gmail_label) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_id).of_type(:integer)  }
      it { should have_db_column(:email_folder_id).of_type(:integer)  }
      it { should have_db_column(:email_folder_type).of_type(:string)  }
      it { should have_db_column(:email_thread_id).of_type(:integer)  }
      it { should have_db_column(:folder_email_date).of_type(:datetime)  }
      it { should have_db_column(:folder_email_draft_id).of_type(:text)  }
      it { should have_db_column(:folder_email_thread_date).of_type(:datetime)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }  
    end

    describe "Indexes" do
      it { should have_db_index([:email_folder_id, :email_folder_type, :email_id]) }
      it { should have_db_index([:email_folder_id, :email_folder_type, :folder_email_thread_date, :email_thread_id, :email_id]) }
      it { should have_db_index([:email_folder_id, :email_folder_type]) }
      it { should have_db_index([:email_id, :email_folder_id, :email_folder_type]) }
      it { should have_db_index([:email_thread_id]) }
      it { should have_db_index([:folder_email_date, :email_id]) }
      it { should have_db_index([:folder_email_date]) }
      it { should have_db_index([:folder_email_draft_id]) }
      it { should have_db_index([:folder_email_thread_date, :email_id]) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :email }
      it { should belong_to :email_thread }
      it { should belong_to :email_folder }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:email_id) }
      it { should validate_presence_of(:email_thread_id) }
      it { should validate_presence_of(:email_folder_id) }
      it { should validate_presence_of(:email_folder_type) }
    end

  end

  ###########################
  ### Callback Unit Tests ###
  ###########################

  describe "Callbacks" do

    describe "After create callbacks" do

      it "calls update_counts method of the email_folder after create" do
        email_folder_mapping = FactoryGirl.build(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: email_folder) 
        email_folder_mapping.email_folder.should_receive(:update_counts)  
        email_folder_mapping.save
      end

    end

    describe "After destroy callbacks" do

      it "calls update_counts method of the email_folder after destoy" do
        email_folder_mapping = FactoryGirl.create(:email_folder_mapping, email: email, email_thread: email_thread, email_folder: email_folder) 
        email_folder_mapping.email_folder.should_receive(:update_counts)  
        email_folder_mapping.destroy
      end

    end

  end

end
