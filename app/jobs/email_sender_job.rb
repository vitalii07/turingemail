class EmailSenderJob
  include Sidekiq::Worker
  include Sidekiq::Status::Worker # sidekiq-status: https://github.com/utgarda/sidekiq-status
  # This job have two sources, one is DelayedEmail#send_and_destroy_at(..) other is EmailAccountsController#send_email
  # the difference is that DelayedEmail also has to be destroyed after being sent.
  sidekiq_options :queue => :mailers

  # delayed_email_id intended to delete it after sending
  # email_data -> serialized as array. order should be exactly the same as on EmailAccountsController and in specs, email_sender_spec (search for :email_params)
  def perform(gmail_account_id, delayed_email_id, email_data=[])
    mutex = RedisMutex.new mutex_key(gmail_account_id, delayed_email_id), expire: 300
    return false if mutex.locked?
    if mutex.lock
      begin
        Email.send_email!(gmail_account_id, delayed_email_id, email_data)
      ensure
        mutex.unlock
      end
    end
  end

  # To be more distinct when used delayed email
  def mutex_key(email_account_id, delayed_email_id)
    "EmailSenderJob:#{email_account_id}:#{delayed_email_id}"
  end

  # Overwrite global expiration (see sidekiq.rb init for default)
  # def expiration
  #   @expiration ||= 60*60*24*30 # 30 days
  # end

end
