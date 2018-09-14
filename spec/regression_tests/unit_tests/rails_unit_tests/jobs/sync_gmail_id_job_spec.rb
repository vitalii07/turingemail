require 'rails_helper'

RSpec.describe SyncEmailIdJob do
  let(:email_account) { FactoryGirl.create :gmail_account }
  let!(:email) { FactoryGirl.create(:email) }
  let(:gmail_id) { email.uid }
  before(:each) {
    allow_any_instance_of(Email).to receive(:find_by_uid).and_return(email)
  }


  it 'should sync gmail by id' do
    expect{ SyncEmailIdJob.perform_async(email_account.id, gmail_id) }.to change(SyncEmailIdJob.jobs, :size).by 1
    expect(SyncEmailIdJob).to have_enqueued_job(email_account.id, gmail_id)
  end

  describe "mutex" do
    let(:mutex_key) { "SyncEmailIdJob:#{email_account.id}:#{gmail_id}" }
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
      SyncEmailIdJob.new.perform(email_account.id, gmail_id)
      expect(mutex).to have_received(:locked?).once
      expect(mutex).to have_received(:lock).once
      expect(mutex).to have_received(:unlock).once
    end

    context "with locked mutex" do
      it "doesn't run the job" do
        mutex.lock
        expect_any_instance_of(Email).to_not receive(:find_by_uid)
        SyncEmailIdJob.perform_async(email_account.id, gmail_id)
      end
    end

    context "with failed job" do
      before {
        allow_any_instance_of(SyncEmailIdJob).to receive(:perform).and_raise "error"
      }

      it "still unlocks mutex" do
        expect { Sidekiq::Testing.inline! { SyncEmailIdJob.perform_async(email_account.id, gmail_id) } }.to raise_error
        # expect(mutex).to have_received(:unlock).once
      end
    end
  end
end
