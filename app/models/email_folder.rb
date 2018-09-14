class EmailFolder < ActiveRecord::Base
  self.abstract_class = true

  @@skip_update_counts = false

  def self.skip_update_counts
    @@skip_update_counts
  end

  def self.skip_update_counts=(val)
    @@skip_update_counts = val
  end

  def self.update_counts(folders)
    return if !folders || folders.empty?
    return if self.skip_update_counts
    folders_map = {}
    folders.each do | folder |
      folder.lock!
      folder.num_unread_threads = 0
      folder.num_threads = 0
      folders_map[folder.id] = folder
    end

    rel = EmailFolderMapping.joins(:email).
        where(:email_folder => folders).
        select(
            'count(DISTINCT emails.email_thread_id) as cnt',
            'count(DISTINCT case when emails.seen then null else emails.email_thread_id end) as not_seen_cnt',
            :email_folder_id).
        group(:email_folder_id)
    rel.to_a.each do | row |
      folder_id = row['email_folder_id']
      folder = folders_map[folder_id]
      folder.num_threads = row['cnt'].to_i
      folder.num_unread_threads = row['not_seen_cnt'].to_i
    end

    folders.each do | folder |
      folder.save!
    end
  end

  # if you need to update several records at once consider using
  # GmailLabels.update_counts(folders) method
  def update_counts
    return if self.class.skip_update_counts

    self.with_lock do
      rel = EmailFolderMapping.joins(:email).
          where(:email_folder => self).
          select('count(DISTINCT emails.email_thread_id) as cnt').
          select('count(DISTINCT case when emails.seen then null else emails.email_thread_id end) as not_seen_cnt')

      row = rel.to_a.first
      self.num_unread_threads = row['not_seen_cnt'].to_i
      self.num_threads = row['cnt'].to_i
      self.save!
    end
  end

  # updates unseen messages counter for several folders at once
  # it could be faster as we use single query to count unseen messages in all folders
  def self.update_num_unread_threads(folders)
    return if !folders || folders.empty?
    return if self.skip_update_counts
    folders_map = {}
    folders.each do | folder |
      folder.lock!
      folder.num_unread_threads = 0
      folders_map[folder.id] = folder
    end

    rel = EmailFolderMapping.joins(:email).
        where(:email_folder => folders).
        where('not emails.seen').
        select('count(DISTINCT emails.email_thread_id) as cnt', :email_folder_id).
        group(:email_folder_id)
    rel.to_a.each do | row |
      folder_id = row['email_folder_id']
      folder = folders_map[folder_id]
      folder.num_unread_threads = row['cnt'].to_i
    end

    folders.each do | folder |
      folder.save!
    end
  end

  # this method creates new transaction for counter update. Sometimes it could be not good from performance point
  # of view. If you need update several records at once, consider using method self.update_num_unread_threads(folders)
  def update_num_unread_threads
    return if self.class.skip_update_counts
    self.with_lock do
      self.num_unread_threads = EmailFolderMapping.joins(:email).where(:email_folder => self).
          where('"emails"."seen" = ?',false).
          count('DISTINCT "emails"."email_thread_id"')
      self.save!
    end
  end

  def self.get_sorted_paginated_threads(email_folder: nil, last_email_thread: nil, dir: 'DESC', threads_per_page: 50, log: false)
    num_rows = threads_per_page
    dir = 'DESC' if dir.blank?

    last_email_sql = ''
    query_params = []
    dir_op = dir.upcase == 'DESC' ? '<' : '>'

    if last_email_thread
      emails = last_email_thread.emails.order(:date => :desc)

      for email in emails
        unless email.draft_id?
          last_email = email
          break
        end
      end

      last_email = emails[0] if last_email.nil?

      query_params.push(last_email.date, last_email_thread.id, last_email.id)
    else
      count_and_max_date = email_folder.emails.select('COUNT(*) as cnt, MAX("emails"."date") as max_date')
      if count_and_max_date[0].cnt > 0
        max_date = count_and_max_date[0].max_date + 1.second
      else
        max_date = DateTime.now()
      end

      query_params.push(max_date, -1, -1)
    end

    last_email_sql = <<last_email_sql
AND
(
  email_folder_mappings."folder_email_thread_date",
  email_folder_mappings."email_thread_id",
  email_folder_mappings."email_id"
)
#{dir_op}
(?, ?, ?)
last_email_sql

    last_email_sql_inner = <<last_email_sql_inner
AND
(
  email_folder_mappings_inner."folder_email_thread_date",
  email_folder_mappings_inner."email_thread_id",
  email_folder_mappings_inner."email_id"
)
#{dir_op}
(
  recent_email_threads."folder_email_thread_date",
  recent_email_threads."email_thread_id",
  recent_email_threads."email_id"
)
last_email_sql_inner
    is_draft_folder = email_folder.present? && (
    (email_folder.instance_of?(GmailLabel) && email_folder.name == "DRAFT") ||
        (email_folder.instance_of?(ImapFolder) && email_folder.name == "Drafts"))

    sql = <<sql
WITH RECURSIVE recent_email_threads AS (
    (SELECT email_folder_mappings."folder_email_thread_date" AS folder_email_thread_date,
            email_folder_mappings."email_thread_id" AS email_thread_id,
            email_folder_mappings."email_id" AS email_id,
            array[email_folder_mappings."email_thread_id"] AS seen
    FROM "email_folder_mappings" AS email_folder_mappings
    WHERE email_folder_mappings."email_folder_id" = #{email_folder.id.to_i} AND
          email_folder_mappings."email_folder_type" = '#{email_folder.class.to_s}'
          #{last_email_sql}
    ORDER BY email_folder_mappings."folder_email_thread_date" #{dir},
             email_folder_mappings."email_thread_id" #{dir},
             email_folder_mappings."email_id" #{dir}
    LIMIT 1)

    UNION ALL

    (SELECT email_folder_mappings_lateral."folder_email_thread_date" AS folder_email_thread_date,
            email_folder_mappings_lateral."email_thread_id" AS email_thread_id,
            email_folder_mappings_lateral."email_id" AS email_id,
            recent_email_threads."seen" || email_folder_mappings_lateral."email_thread_id"
    FROM recent_email_threads,
    LATERAL (SELECT email_folder_mappings_inner."folder_email_thread_date",
                    email_folder_mappings_inner."email_thread_id",
                    email_folder_mappings_inner."email_id"
            FROM "email_folder_mappings" AS email_folder_mappings_inner
            WHERE #{'email_folder_mappings_inner."folder_email_draft_id" IS NULL AND ' if !is_draft_folder}
                  email_folder_mappings_inner."email_folder_id" = #{email_folder.id.to_i} AND
                  email_folder_mappings_inner."email_folder_type" = '#{email_folder.class.to_s}' AND
                  email_folder_mappings_inner."email_thread_id" <> ALL (recent_email_threads."seen")
                  #{last_email_sql_inner}
            ORDER BY email_folder_mappings_inner."folder_email_thread_date" #{dir},
                     email_folder_mappings_inner."email_thread_id" #{dir},
                     email_folder_mappings_inner."email_id" #{dir}
            LIMIT 1)
      AS email_folder_mappings_lateral
    WHERE array_upper(recent_email_threads."seen", 1) < #{num_rows})
)
SELECT email_threads.*
       FROM email_threads
       WHERE id IN (SELECT recent_email_threads."email_thread_id"
                    FROM recent_email_threads
                    LIMIT #{threads_per_page})
sql

    if log
      log_console(sql)
      log_console(query_params)
    end

    query_params.unshift(sql)
    email_threads_ids = EmailThread.find_by_sql(query_params).map(&:id)
    email_threads = EmailThread.includes(:latest_email => [:email_attachments, :email_attachment_uploads, :gmail_labels]).
        where(:id => email_threads_ids).
        order("#{'emails.draft_id NULLS FIRST, ' if !is_draft_folder}emails.date DESC, email_threads.id DESC")

    return email_threads
  end

  def apply_to_emails(email_ids)
    email_folder_mappings = []

    email_ids.each do |email_id|
      begin
        if email_id.class == Email
          email = email_id
          email_folder_mappings << EmailFolderMapping.find_or_create_by!(:email => email_id, :email_folder => self,
                                                                         :folder_email_thread_date => email.email_thread.emails.maximum(:date),
                                                                         :folder_email_date => email.date, :folder_email_draft_id => email.draft_id,
                                                                         :email_thread => email.email_thread)
        else
          email = Email.find_by(:id => email_id)
          next if email.nil?
          email_folder_mappings << EmailFolderMapping.find_or_create_by!(:email_id => email_id, :email_folder => self,
                                                                         :folder_email_thread_date => email.email_thread.emails.maximum(:date),
                                                                         :folder_email_date => email.date, :folder_email_draft_id => email.draft_id,
                                                                         :email_thread => email.email_thread)
        end
      rescue ActiveRecord::RecordNotUnique
        email_folder_mappings << nil
      end
    end

    return email_folder_mappings
  end

end