require 'rails_helper'

RSpec.describe EmailAttachmentUploader do
  let(:s3_key) { s3_get_new_key() }
  let(:uploader) { EmailAttachmentUploader.new }
  describe "S3 storage" do
    describe "#url" do
      it "equals to the s3_url" do
        uploader.retrieve_from_store!(s3_key)
        expect(uploader.url).to eq s3_url(s3_key)
      end
    end

    describe "#store!" do
      let(:file) { File.open "spec/support/data/misc/1x1.gif" }

      it "stores with s3_key name" do
        uploader.store! file
        expect(uploader.filename.length).to eq $config.s3_key_length
        expect(uploader.url).to eq s3_url(uploader.filename)
      end
    end
  end
end
