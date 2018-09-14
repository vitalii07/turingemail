require 'rails_helper'

RSpec.describe SyncAccountJob do
  let(:gmail_account) { FactoryGirl.create :gmail_account }
  before(:each) {
    allow_any_instance_of(GmailAccount).to receive(:sync_account)
  }

  it "calls #sync_account for gmail account" do
    expect_any_instance_of(GmailAccount).to receive(:sync_account).once
    SyncAccountJob.perform_now(gmail_account.id)
  end

  it 'should not call sync account for suspended account' do
    $config.suspend_at_count.times { gmail_account.suspend! }
    expect_any_instance_of(GmailAccount).not_to receive(:sync_account)
    SyncAccountJob.perform_now(gmail_account.id)
  end

  it 'should not suspend account before desired time' do
    times = $config.suspend_at_count - 3
    times.times { gmail_account.suspend! }
    expect(gmail_account.suspended?).to eq false
    expect_any_instance_of(GmailAccount).to receive(:sync_account)
    SyncAccountJob.perform_now(gmail_account.id)
  end

  it 'should reset suspend counter on successful sync' do
    gmail_account.suspend!
    expect(gmail_account.auth_errors_counter).to eq 1
    expect(gmail_account.suspended?).to eq false
    SyncAccountJob.perform_now(gmail_account.id)
    gmail_account.reload
    expect(gmail_account.suspended?).to eq false
    expect(gmail_account.auth_errors_counter).to eq 0
  end

  it 'should delete SyncAccountJob for totally suspended account' do
    create_job = nil
    assert_enqueued_jobs 1 do
      create_job = SyncAccountJob.perform_later(gmail_account.id)
    end
    gmail_account.set_job_uid!(create_job.job_id)
    $config.suspend_at_count.times { gmail_account.suspend! }
    expect(gmail_account.sync_delayed_job_uid).to eq nil
  end

  describe "time delay" do
    let(:gmail_account) { FactoryGirl.create :gmail_account, last_sync_at: last_sync_at }

    context "with enough delay" do
      let(:last_sync_at) { (SyncAccountJob::MINIMUM_DELAY + 1).ago }

      it "performs the job" do
        expect_any_instance_of(GmailAccount).to receive(:sync_account).once
        SyncAccountJob.perform_now(gmail_account.id)
      end
    end

    context "with not enough delay" do
      let(:last_sync_at) { (SyncAccountJob::MINIMUM_DELAY - 1).ago }

      it "doesn't perform the job" do
        expect_any_instance_of(GmailAccount).to_not receive(:sync_account)
        SyncAccountJob.perform_now(gmail_account.id)
      end
    end
  end

  describe "mutex" do
    let(:mutex_key) { "SyncAccountJob:#{gmail_account.id}" }
    let(:mutex) do
      mutex = instance_double(RedisMutex)
      allow(mutex).to receive(:lock) { @locked ? false : (@locked = true) }
      allow(mutex).to receive(:unlock) { @locked = false ; true }
      allow(mutex).to receive(:locked?) { @locked ||= false }
      mutex
    end
    before do
      allow(RedisMutex).to receive(:new).with(mutex_key, anything).and_return mutex
    end

    it "locks the mutex" do
      SyncAccountJob.perform_now(gmail_account.id)
      expect(mutex).to have_received(:locked?).once
      expect(mutex).to have_received(:lock).once
      expect(mutex).to have_received(:unlock).once
    end

    context "with locked mutex" do
      it "doesn't run the job" do
        mutex.lock
        expect_any_instance_of(GmailAccount).to_not receive(:sync_account)
        SyncAccountJob.perform_now(gmail_account.id)
      end
    end

    context "with failed job" do
      before {
        allow_any_instance_of(GmailAccount).to receive(:sync_account).and_raise "error"
      }

      it "still unlocks mutex" do
        expect {
          SyncAccountJob.perform_now(gmail_account.id)
        }.to raise_error
        expect(mutex).to have_received(:unlock).once
      end
    end
  end
end
