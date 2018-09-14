# == Schema Information
#
# Table name: email_accounts
#
#  id                     :integer          not null, primary key
#  user_id                :integer
#  service_id             :text
#  service_type           :text
#  email                  :text
#  verified_email         :boolean
#  sync_started_time      :datetime
#  last_history_id_synced :text
#  last_sync_at           :datetime
#  last_sign_in_at        :datetime         default(Thu, 09 Jul 2015 21:59:23 UTC +00:00)
#  sync_delayed_job_uid   :string
#  auth_errors_counter    :integer          default(0)
#  last_suspend_at        :datetime
#  type                   :string
#  created_at             :datetime
#  updated_at             :datetime
#  last_push_setup_at     :datetime
#  initial_sync_has_run   :boolean          default(FALSE)
#

class EmailAccount < ActiveRecord::Base

  #################
  ### Constants ###
  #################

  MESSAGE_BATCH_SIZE = 100
  DRAFTS_BATCH_SIZE = 100
  HISTORY_BATCH_SIZE = 100
  SEARCH_RESULTS_PER_PAGE = 50
  NUM_SYNC_DYNOS = 3

  #####################
  ### Relationships ###
  #####################

  belongs_to :user

  has_many :email_threads,
           :as => :email_account,
           :dependent => :destroy

  has_many :email_conversations,
           -> { order(date: :desc) },
           :as => :email_account,
           :dependent => :destroy

  has_many :emails,
           :as => :email_account,
           :dependent => :destroy

  has_many :email_attachments,
           :through => :emails

  has_many :people,
           :as => :email_account,
           :dependent => :destroy

  has_many :sync_failed_emails,
           :as => :email_account,
           :dependent => :destroy

  has_many :delayed_emails,
           :as => :email_account,
           :dependent => :destroy

  has_many :email_trackers,
           :as => :email_account,
           :dependent => :destroy

  has_many :email_filters,
           :dependent => :destroy

  has_many :email_tracker_recipients,
           :through => :email_trackers

  has_many :email_tracker_views,
           :through => :email_tracker_recipients

  has_many :list_subscriptions,
           :as => :email_account,
           :dependent => :destroy

  has_one :inbox_cleaner_report,
          dependent: :destroy

  ###############################
  ### Synchronization Methods ###
  ###############################

  def sync_account(force = false)
    log_console("sync_account for #{self.email}")

    self.sync_email_folders()
    self.sync_email force: force

    touch :last_sync_at
  end

  def sync_account_unless_already_in_sync
    unless already_in_sync? # prevent creating job before ending current
      job_id = SyncAccountJob.perform_later(self.id).job_id
      set_job_uid!(job_id)
    end
  end

  ###############
  ### Actions ###
  ###############

  def self.emails_set_seen(email_account_id, email_ids, seen)
    email_account = EmailAccount.find(email_account_id)
    emails = Email.includes(:gmail_labels).where(:id => email_ids) # includes will reduce the multiple calls for searching gmail labels for each mail
    email_account.emails_set_seen(emails, seen)
  end

  def self.remove_emails_from_folder(email_account_id, email_ids, folder_id)
    email_account = EmailAccount.find(email_account_id)
    emails = Email.where(:id => email_ids)
    email_account.remove_emails_from_folder(emails, folder_id: folder_id)
  end

  def self.trash_emails(email_account_id, email_ids)
    email_account = EmailAccount.find(email_account_id)
    emails = Email.where(:id => email_ids)
    email_account.trash_emails(emails)
  end

  ##########################################
  ### Interface Methods to be overridden ###
  ##########################################

  def setup_push_channel
  end

  def self.get_userinfo(api_client)
  end

  def refresh_user_info(api_client = nil, do_save = true)
  end

  ############
  ### Misc ###
  ############

  def delete_o_auth2_token
    if self.o_auth2_token
      self.o_auth2_token.destroy()
      self.o_auth2_token = nil
    end
  end

  #################################
  ### Background Worker Methods ###
  #################################

  def active?
    !suspended? && self.user.updated_at > Time.now - $config.max_account_inactive_period.days
  end

  def suspended?
    auth_errors_counter >= $config.suspend_at_count
  end

  def at_least_suspended?
    auth_errors_counter != 0
  end

  # :on will suspend (add +1 to auth_errors_counter), :off will set 'active'
  def suspend!(way = :on)
    now = Time.now
    if way == :on
      # ensure we wont fall on fresh record.
      last_suspend_time = last_suspend_at || ($config.suspend_days_threshold + 1).days.ago
      days_diff = Time.at((now - last_suspend_time).to_i.abs).utc.strftime('%d').to_i # extract days difference
      if days_diff > $config.suspend_days_threshold
        new_value = 1
      else
        new_value = auth_errors_counter + 1
      end
      self.last_suspend_at = now
    else
      new_value = 0 # reset when :off
    end
    log_console("GmailAccount##{id} #{way == :on ? "Suspend change #{auth_errors_counter}>#{new_value}" : 'SET to active'}")
    self.auth_errors_counter = new_value
    save!
    # remove last SyncAccountJob from its queue
    delete_sync_job if way == :on && sync_delayed_job_uid.present?
    true
  end

  # Return true if deleted or nil if not.
  # this will stop only last job, unless we limit only one job per self. (with .already_in_sync?)
  def delete_sync_job
    job = find_sync_job
    set_job_uid! # clean attr from db
    return job.delete if job
  end

  def set_job_uid!(job_uid=nil)
    update_attribute(:sync_delayed_job_uid, job_uid)
  end

  # Return object of class Sidekiq::Job
  # note: it will find only latest job. TODO we can change it to find by args. and delete all
  def find_sync_job
    jobs = Sidekiq::Queue.new(SyncAccountJob.queue_name)
    # to find all jobs(consider that SyncAccountJob worker has only id argument):
    # all_my_jobs = jobs.select{|j| j.args[0]['arguments'] == [self.id] } #=> Array of Sidekiq::Job
    return jobs.select{|j| j.args[0]['job_id'] == sync_delayed_job_uid }.first
  end

  def already_in_sync?
    return already_in_sync_via_a_worker? || already_in_sync_via_a_queued_job?
  end

  def already_in_sync_via_a_worker?
    Sidekiq::Workers.new.each do |process_id, thread_id, work|
      if work["queue"] == "sync_account" and work["payload"]["args"][0]["job_class"] == 'SyncAccountJob'
        return true if work["payload"]["args"][0]["arguments"][0] == self.id
      end
    end
    return false
  end

  def already_in_sync_via_a_queued_job?
    Sidekiq::Queue.new("sync_account").each do |job|
      return true if job.args[0]["arguments"][0] == self.id
    end
    return false
  end

end
