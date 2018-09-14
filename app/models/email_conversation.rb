# == Schema Information
#
# Table name: email_conversations
#
#  id                 :integer          not null, primary key
#  emails_count       :integer
#  email_account_id   :integer
#  email_account_type :string(255)
#  date               :datetime
#  created_at         :datetime         not null
#  updated_at         :datetime         not null
#

class EmailConversation < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true

  has_many :emails, -> { order(date: :desc) }

  has_and_belongs_to_many :persons

  validates :email_account, presence: true

  def self.search(email_account, q)
    rel = where(email_account: email_account).order(date: :desc)
    q.strip! if q.present?
    if q.present?
      q = '%' + q + '%'
      rel = rel.joins(:persons).
          where('people.email_address ilike ? or people.name ilike ?', q, q).
          group('email_conversations.id')
    end
    return rel
  end
end
