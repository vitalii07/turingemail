# == Schema Information
#
# Table name: ip_infos
#
#  id           :integer          not null, primary key
#  ip           :inet
#  country_code :text
#  country_name :text
#  region_code  :text
#  region_name  :text
#  city         :text
#  zipcode      :text
#  latitude     :text
#  longitude    :text
#  metro_code   :text
#  area_code    :text
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

RSpec.describe IpInfo, :type => :model do
  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:ip).of_type(:inet)  }
      it { should have_db_column(:country_code).of_type(:text)  }
      it { should have_db_column(:country_name).of_type(:text)  }
      it { should have_db_column(:region_code).of_type(:text)  }
      it { should have_db_column(:region_name).of_type(:text)  }
      it { should have_db_column(:city).of_type(:text)  }
      it { should have_db_column(:zipcode).of_type(:text)  }
      it { should have_db_column(:latitude).of_type(:text)  }
      it { should have_db_column(:longitude).of_type(:text)  }
      it { should have_db_column(:metro_code).of_type(:text)  }
      it { should have_db_column(:area_code).of_type(:text)  }
      it { should have_db_column(:fetched).of_type(:boolean)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

    describe "Indexes" do
      it { should have_db_index(:ip) }
    end

  end

  ##############################
  ### Association Unit Tests ###
  ##############################

  describe "Relationships" do

    describe "Have many relationships" do
      it { should have_many(:emails) }
    end

  end

  #############################
  ### Validation Unit Tests ###
  #############################

  describe "Validations" do

    describe "Presence validations" do
      it { should validate_presence_of(:ip) }
    end

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
      ### Action Class Method Unit Tests ###
      ######################################

      describe "Action class methods" do

        describe "#find_latest_or_create_by_ip" do

          it 'returns the latest ip_info instance from the ip' do
            ip = FFaker::Internet.ip_v4_address
            FactoryGirl.create(:ip_info, ip: ip)

            expected = IpInfo.where(ip: ip).order("created_at DESC").first

            expect(IpInfo.find_latest_or_create_by_ip(ip)).to eq(expected)
          end

          it 'It doesn\'t return records older than 3 months' do
            ip = FFaker::Internet.ip_v4_address
            FactoryGirl.create(:ip_info, ip: ip, created_at: 5.months.ago, updated_at: 4.months.ago)

            ip_info_array = IpInfo.where(ip: ip).to_a

            ip_info = IpInfo.find_latest_or_create_by_ip(ip)

            expect(ip_info_array).not_to include(ip_info)
          end

          it 'creates a new ip_info record if the old ip_info with same ip is more that 3 months old' do
            ip = FFaker::Internet.ip_v4_address
            FactoryGirl.create(:ip_info, ip: ip, created_at: 5.months.ago, updated_at: 4.months.ago)

            count = IpInfo.count

            ip_info = IpInfo.find_latest_or_create_by_ip(ip)

            expect(count + 1).to eq(IpInfo.count)
          end

          context "when the ip_info with the ip does not exist" do
            let(:ip) { FFaker::Internet.ip_v4_address }

            context "in the production environment" do
              before(:each) {
                allow(Rails.env).to receive(:production?) { true }
              }

              it 'creates new ip_info' do

                IpInfo.find_latest_or_create_by_ip(ip)

                ip_info = IpInfo.find_by_ip(ip)

                expect(ip_info).not_to be(nil)
              end
            end
          end
        end #__End of describe "#from_ip"__

      end

    end

  end

end