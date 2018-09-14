# == Schema Information
#
# Table name: email_attachment_uploads
#
#  id          :integer          not null, primary key
#  user_id     :integer
#  email_id    :integer
#  uid         :text
#  s3_key      :text
#  s3_key_full :text
#  filename    :text
#  created_at  :datetime
#  updated_at  :datetime
#

require 'rails_helper'

RSpec.describe EmailAttachmentUpload, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }
  let!(:email) { FactoryGirl.create(:email) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:user_id).of_type(:integer)  }
      it { should have_db_column(:email_id).of_type(:integer)  }
      it { should have_db_column(:uid).of_type(:text)  }
      it { should have_db_column(:s3_key).of_type(:text)  }
      it { should have_db_column(:s3_key_full).of_type(:text)  }
      it { should have_db_column(:filename).of_type(:text)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  } 
    end

    describe "Indexes" do
      it { should have_db_index(:email_id) }
      it { should have_db_index(:s3_key).unique(true) }
      it { should have_db_index(:s3_key_full).unique(true) }
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
      it { should belong_to :email }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Custom validations" do

      it "populates the uid before validation" do
        email_attachment_upload = FactoryGirl.build(:email_attachment_upload, user: user, email: email, uid: nil)
         
        expect(email_attachment_upload.save).to be(true)
      end

      it "populates the s3_key before validation" do
        email_attachment_upload = FactoryGirl.build(:email_attachment_upload, user: user, email: email, s3_key: nil)
         
        expect(email_attachment_upload.save).to be(true)
      end

    end

    describe "Presence validations" do
      it { should validate_presence_of(:user) }
    end

  end

  ###########################
  ### Callback Unit Tests ###
  ###########################

  describe "Callbacks" do

    describe "Before destroy callbacks" do

      context "when the s3_key exists" do
        let(:email_attachment_upload) { FactoryGirl.create(:email_attachment_upload, user: user, email: email) }

        it "deletes the s3 before destroy" do

          allow(EmailAttachmentUpload).to receive(:delay).and_call_original
           
          email_attachment_upload.destroy
        end

      end #__End of describe ":before_destroy"__

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
      ### Getter Instance Method Unit Tests ###
      #########################################

      describe "Getter instance methods" do

        describe ".s3_path" do

          let!(:email_attachment_upload) { FactoryGirl.create(:email_attachment_upload, user: user, email: email) }

          context 'when user is nil' do
            it "returns nil" do
              email_attachment_upload.user = nil
              expect(email_attachment_upload.s3_path).to be(nil)
            end
          end
          
          context 'when s3_key is nil' do
            it "returns nil" do
              email_attachment_upload.s3_key = nil
              expect(email_attachment_upload.s3_path).to be(nil)
            end
          end

          context "with present filename" do
            it "returns the s3 path" do
              email_attachment_upload.filename = "file.txt"
              expected = "uploads/#{email_attachment_upload.user.id}/#{email_attachment_upload.s3_key}/file.txt"
              expect(email_attachment_upload.s3_path).to eq(expected)
            end
          end

          context "with empty filename" do
            it "returns the s3 path" do
              expected = "uploads/#{email_attachment_upload.user.id}/#{email_attachment_upload.s3_key}/${filename}"
              expect(email_attachment_upload.s3_path).to eq(expected)
            end
          end
        end #__End of describe ".s3_path"__

        describe ".presigned_post" do

          let!(:email_attachment_upload) { FactoryGirl.create(:email_attachment_upload, user: user, email: email) }

          context 'when user is nil' do
            it "returns nil" do
              email_attachment_upload.user = nil
              expect(email_attachment_upload.s3_path).to be(nil)
            end
          end
          
          context 'when s3_key is nil' do
            it "returns nil" do
              email_attachment_upload.s3_key = nil
              expect(email_attachment_upload.s3_path).to be(nil)
            end
          end

          it "returns the presigned_post" do
            expect(email_attachment_upload.presigned_post.class).to eq(AWS::S3::PresignedPost)
          end
        end #__End of describe ".presigned_post"__

      end

    end

  end

end
