# == Schema Information
#
# Table name: mail_server_credential
#
#  id           :integer          not null, primary key
#  imap_url     :string
#  smtp_url     :string
#  api_id       :integer
#  api_type     :string
#  created_at   :datetime
#  updated_at   :datetime
#

require 'rails_helper'

RSpec.describe MailServerCredential, :type => :model do
  ###########################
  ### Database Unit Tests ###
  ###########################

  describe "Database" do

    describe "Columns" do
      it { should have_db_column(:imap_url).of_type(:string)  }
      it { should have_db_column(:smtp_url).of_type(:string)  }
      it { should have_db_column(:api_id).of_type(:integer)  }
      it { should have_db_column(:api_type).of_type(:string)  }
      it { should have_db_column(:created_at).of_type(:datetime)  }
      it { should have_db_column(:updated_at).of_type(:datetime)  }
    end

  end

end