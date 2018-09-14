require 'rails_helper'

RSpec.describe GoogleContact, :type => :model do
  let!(:google_contact) { FactoryGirl.create :google_contact }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_account_id).of_type(:integer)  }
      it { should have_db_column(:email_account_type).of_type(:string)  }
      it { should have_db_column(:contact_title).of_type(:string)  }
      it { should have_db_column(:contact_email).of_type(:string)  }
      it { should have_db_column(:contact_picture).of_type(:string)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
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

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of :email_account }
      it { should validate_presence_of :contact_email }
    end

  end

  #########################
  ### Method Unit Tests ###
  #########################

  describe "Methods" do

    ######################################
    ### Action Class Method Unit Tests ###
    ######################################

    describe "Action class methods" do

      describe "#create_or_update_contact" do
        it "is pending spec implementation"
      end

    end

    ##################################
    ### Instance Method Unit Tests ###
    ##################################

    describe "Instance methods" do

      #########################################
      ### Action Instance Method Unit Tests ###
      #########################################

      describe "Action instance methods" do

        describe ".upload_picture_from_url!" do

          it 'should upload and update contact_picture' do
            url = 'http://static.comicvine.com/uploads/original/5/59300/4586078-5654268829-38709.jpg'
            uploaded_url = google_contact.upload_picture_from_url!(url)
            expect(uploaded_url).to include('https://s3.amazonaws.com')
          end

        end

      end

    end

  end

end
