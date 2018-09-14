# == Schema Information
#
# Table name: email_threads
#
#  id                 :integer          not null, primary key
#  email_account_id   :integer
#  email_account_type :string
#  uid                :text
#  emails_count       :integer
#  created_at         :datetime
#  updated_at         :datetime
#

class EmailThread < ActiveRecord::Base
  belongs_to :email_account, polymorphic: true

  has_many :emails,
           -> { order date: :desc },
           dependent: :destroy

  has_many :people, through: :emails

  # To include only first email. Can't use it right now as we need to include all mails to provide backward support for
  # count queries. Once we update all columns then we can use this method to reduce some load on in_folder method.
  has_one :latest_email, -> { order date: :desc }, class_name: "Email"

  validates :email_account, :uid, presence: true

  def EmailThread.get_threads_from_ids(ids)
    email_threads = EmailThread.includes(:emails).where(:id => ids)
    return email_threads
  end

  def user
    return self.email_account.user
  end

  scope :order_by_max_email_date, -> {
    order('(select max(date) from emails e where e.email_thread_id = email_threads.id) desc')
  }

  # Full-text search
  scope :search_threads,->(account_id, query) {
    # we limit maximum size of expression used for full-text search to 800000 symbols to prevent 'too big for ts_vector' error
    # in order to use indexeing during search we need to create gin index in database on exactly same expression
    sql = <<search_sql
exists (
  select 1 from
    emails e
  where
    e.email_thread_id = email_threads.id
    and to_tsvector('english', substring(coalesce(subject, ' ') || coalesce(from_name, ' ') || coalesce(from_address, ' ') || coalesce(text_part, ' ') || coalesce(html_part, ' ') || coalesce(body_text, ' '), 1, 800000)) @@ plainto_tsquery('english', ?)
    and not exists (
      select 1 from
        email_folder_mappings efm
      where
        efm.email_id = e.id
        and (
          (
            efm.email_folder_type = 'GmailLabel'
            and exists (select 1 from gmail_labels gl where gl.id = efm.email_folder_id and gl.name = 'TRASH')
          )
          or (
            efm.email_folder_type = 'ImapFolder'
            and exists (select 1 from imap_folders if where if.id = efm.email_folder_id and if.name in ('Junk', 'Trash', 'Deleted', 'Deleted Messages'))
          )
        )
    )
)

search_sql
    return where(email_account_id: account_id).where(sql, query)
  }
end
