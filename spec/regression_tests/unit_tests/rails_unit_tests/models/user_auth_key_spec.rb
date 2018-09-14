# == Schema Information
#
# Table name: user_auth_keys
#
#  id                 :integer          not null, primary key
#  user_id            :integer
#  encrypted_auth_key :text
#  created_at         :datetime
#  updated_at         :datetime
#

require 'rails_helper'

RSpec.describe UserAuthKey, :type => :model do
  let!(:user) { FactoryGirl.create(:user) }

  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:user_id).of_type(:integer)  }
      it { should have_db_column(:encrypted_auth_key).of_type(:text)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index(:encrypted_auth_key) }
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

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Custom validations" do

      it "populates the encrypted_auth_key before validation" do

        user_auth_key = FactoryGirl.build(:user_auth_key, user: user, encrypted_auth_key: nil)

        user_auth_key.valid?

        expect(user_auth_key.encrypted_auth_key.present?).to be(true)
      end

    end

    describe "Presence validations" do
      it { should validate_presence_of(:user) }
    end

    describe "Uniqueness validations" do
    end

  end

  it "deletes the cache after commit" do
    user_auth_key = FactoryGirl.build(:user_auth_key, user: user)
    expect(Rails.cache).to receive(:delete)
    user_auth_key.save
  end

  #########################
  ### Method Unit Tests ###
  #########################

  describe "Methods" do

    ###############################
    ### Class Method Unit Tests ###
    ###############################

    describe "Class methods" do

      ######################################
      ### Getter Class Method Unit Tests ###
      ######################################

      describe "Getter class methods" do

        describe "#secure_hash" do
          let(:data) { "input data" }

          it 'returns the secure hash' do

            allow(Digest::SHA1).to receive(:hexdigest).with(data).and_call_original

            UserAuthKey.secure_hash(data)
          end
        end #__End of describe "#secure_hash"__

        describe "#new_key" do

          it 'returns the new key' do

            allow(SecureRandom).to receive(:urlsafe_base64).and_call_original

            UserAuthKey.new_key
          end
        end #__End of describe "#new_key"__

        describe ".cached_find_by_encrypted_auth_key" do
          let!(:user_auth_key) { FactoryGirl.create(:user_auth_key, user: user) }

          it 'fetches the user auth key by encrypted_auth_key' do
            expect( UserAuthKey.cached_find_by_encrypted_auth_key(user_auth_key.encrypted_auth_key) ).to eq( user_auth_key )
          end
        end #__End of describe "#new_key"__

      end

    end

  end

end
