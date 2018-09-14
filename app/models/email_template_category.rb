# == Schema Information
#
# Table name: email_template_categories
#
#  id                    :integer          not null, primary key
#  user_id               :integer
#  uid                   :text
#  name                  :text
#  email_templates_count :integer
#  created_at            :datetime
#  updated_at            :datetime
#

class EmailTemplateCategory < ActiveRecord::Base
  belongs_to :user

  has_many :email_templates

  validates :user, :uid, :name, presence: true

  before_validation { self.uid = SecureRandom.uuid() if self.uid.nil? }
end
