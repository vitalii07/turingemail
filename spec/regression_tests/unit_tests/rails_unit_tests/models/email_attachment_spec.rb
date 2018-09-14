# == Schema Information
#
# Table name: email_attachments
#
#  id                  :integer          not null, primary key
#  email_id            :integer
#  filename            :text
#  content_type        :text
#  file_size           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  uid                 :text
#  mime_type           :text
#  content_disposition :text
#  sha256_hex_digest   :text
#  gmail_attachment_id :text
#  s3_key              :text
#

require 'rails_helper'

RSpec.describe EmailAttachment, :type => :model do
  let!(:email) { FactoryGirl.create(:email) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:email_id).of_type(:integer)  }
      it { should have_db_column(:filename).of_type(:text)  }
      it { should have_db_column(:content_type).of_type(:text)  }
      it { should have_db_column(:file_size).of_type(:integer)  }
      it { should have_db_column(:uid).of_type(:text)  }
      it { should have_db_column(:mime_type).of_type(:text)  }
      it { should have_db_column(:content_disposition).of_type(:text)  }
      it { should have_db_column(:sha256_hex_digest).of_type(:text)  }
      it { should have_db_column(:gmail_attachment_id).of_type(:text)  }
      it { should have_db_column(:s3_key).of_type(:text)  }
      it { should have_db_column(:file).of_type(:text)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index(:content_type) }
      it { should have_db_index(:email_id) }
      it { should have_db_index(:uid).unique(true) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Belongs to relationships" do
      it { should belong_to :email }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Custom validations" do

      it "populates the uid before validation" do
        email_attachment = FactoryGirl.build(:email_attachment, email: email, uid: nil)

        expect(email_attachment.save).to be(true)
      end

    end

    describe "Presence validations" do
      it { should validate_presence_of(:email) }
      it { should validate_presence_of(:file_size) }
    end

  end

  ###########################
  ### Callback Unit Tests ###
  ###########################

  describe "Callbacks" do

    describe "Before destroy callbacks" do

      context "when the s3_key exists" do
        let(:attachment_to_destroy) { FactoryGirl.create :email_attachment, file: nil }

        it "deletes the s3 before destroy" do

          allow(EmailAttachment).to receive(:delay).and_call_original

          attachment_to_destroy.destroy
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

        describe ".file_url" do
          let(:file) { File.open "spec/support/data/misc/1x1.gif" }
          let(:attachment) { FactoryGirl.create :email_attachment, file: file }

          it "returns the file url" do
            expect(attachment.file_url).to eq(attachment.file.url())
          end
        end

        describe ".file" do
          let(:attachment) { FactoryGirl.build(:email_attachment) }
          let(:file) { File.open "spec/support/data/misc/1x1.gif" }

          context "with emply file" do
            let(:attachment) { FactoryGirl.create :email_attachment, file: nil }
            specify { expect(attachment.file).to be_blank }
          end

          describe "uploading" do
            let(:attachment) { EmailAttachment.new email: email }

            it "uploads the file" do
              attachment.file = file
              attachment.save!

              expect(attachment.file_url).to eq s3_url(attachment.read_attribute(:file))
              response = RestClient::Request.execute(:url => attachment.file_url, :method => :get, :verify_ssl => false)
              expect(response.headers[:content_type]).to eq "image/gif"
              expect(response.headers[:content_disposition]).to eq 'attachment; filename="1x1.gif"'

              expect(attachment.filename).to eq "1x1.gif"
              expect(attachment.content_type).to eq "image/gif"
              expect(attachment.file_size).to eq 43
              expect(attachment.sha256_hex_digest).to eq "e7939a03248bb3f75e2f12226871e6e304b0c1e1fa506f3871548547cf24f32d"
            end

            context "with custom filename and content-type" do
              it "overrides Content-Disposition and Content-Type headers" do
                attachment.filename = "1x1.png"
                attachment.content_type = "image/png"
                attachment.file = file
                attachment.save!

                expect(attachment.filename).to eq "1x1.png"
                expect(attachment.content_type).to eq "image/png"

                response = RestClient::Request.execute(:url => attachment.file_url, :method => :get, :verify_ssl => false)
                expect(response.headers[:content_type]).to eq "image/png"
                expect(response.headers[:content_disposition]).to eq 'attachment; filename="1x1.png"'

              end
            end
          end
        end

        describe ".file_from_mail_part" do
          let(:email_raw) { Mail.read("spec/support/data/emails/with_attachments/email_1.txt") }
          let(:attachment) { email_raw.attachments.first }
          let(:email_attachment) { EmailAttachment.new email: email }
          specify do
            email_attachment.file_from_mail_part(attachment)
            email_attachment.save!

            expect(email_attachment.filename).to eq('Health Promotions Specialist FTR92014 - APIWC.pdf')
            expect(email_attachment.content_type).to eq('application/pdf')
            expect(email_attachment.file_size).to eq(92918)
          end

        end

        #################################################
        ### Boolean Getter Instance Method Unit Tests ###
        #################################################

        describe "Boolean getter instance methods" do

          describe ".has_thumb?" do
            let(:email_attachment) { EmailAttachment.new email: email }

            describe "when the email attachment does not have a file" do
              before do
                allow(email_attachment).to receive(:file) { nil }
              end

              it "return false" do
                expect(email_attachment.has_thumb?).to be(false)
              end

            end

            describe "when the email attachment does have a file" do
              let(:file1) { File.open "spec/support/data/misc/1x1.gif" }
              let(:file2) { File.open "spec/support/data/misc/1x1.gif" }
              before do
                thumb = {}
                allow(thumb).to receive(:file) { file2 }
                allow(file1).to receive(:thumb) { thumb }
                allow(email_attachment).to receive(:file) { file1 }
              end

              describe "when the thumb exists" do
                before do
                  allow(file2).to receive(:exists?) { true }
                end

                it "return true" do
                  expect(email_attachment.has_thumb?).to be(true)
                end

              end

              describe "when the thumb does not exist" do
                before do
                  allow(file2).to receive(:exists?) { false }
                end

                it "return false" do
                  expect(email_attachment.has_thumb?).to be(false)
                end

              end

            end

          end

        end

      end

    end

    ###############################
    ### Class Method Unit Tests ###
    ###############################

    describe "Class methods" do

      describe "#order_and_filter" do
        it "is pending spec implementation"
      end

    end

  end

end
