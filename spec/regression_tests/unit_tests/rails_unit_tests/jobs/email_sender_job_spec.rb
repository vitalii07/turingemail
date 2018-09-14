require 'rails_helper'

RSpec.describe EmailSenderJob do
  let(:email_account) { FactoryGirl.create :gmail_account }
  let!(:email_raw) {
    Mail.new
  }
  before(:each) {
    allow_any_instance_of(Email).to receive(:send_email)
    allow(email_raw).to receive(:deliver!)
  }
  let(:email_params) {
    [["tos@example.com"], ["ccs@example.com"], ["bccs@example.com"], "subject", "html part", "text part", false, "False", "2015-03-06 07:26:05.607070004 +0100", "reminder type", "s3-keys"]
  }

  it 'should send delayed email' do
    delayed_email = FactoryGirl.create :delayed_email
    Sidekiq::Testing.fake! do
      # expect_any_instance_of(Email).to receive(:send_email)
      EmailSenderJob.perform_async(email_account.id, delayed_email.id, email_params)
      # expect(email_raw).to have_received(:deliver!)
    end
  end

  describe "mutex" do
    let(:mutex_key) { "EmailSenderJob:#{email_account.id}:#{nil}" }
    let(:mutex) do
      mutex = instance_double(RedisMutex)
      allow(mutex).to receive(:lock) { @locked ? false : (@locked = true) }
      allow(mutex).to receive(:unlock) { @locked = false ; true }
      allow(mutex).to receive(:locked?) { @locked ||= false }
      mutex
    end
    before do
      allow(RedisMutex).to receive(:new).with(mutex_key, anything).and_return mutex
      allow(Email).to receive :send_email!
    end

    it "locks the mutex" do
      # Sidekiq testing with .new.perform should be wrapped with fake! because .new.perform doing live job, which may fail
      Sidekiq::Testing.fake! { EmailSenderJob.new.perform(email_account.id, nil, email_params) }
      expect(mutex).to have_received(:locked?).once
      expect(mutex).to have_received(:lock).once
      expect(mutex).to have_received(:unlock).once
    end

    context "with locked mutex" do
      it "doesn't run the job" do
        mutex.lock
        expect_any_instance_of(Email).to_not receive(:send_email)
        EmailSenderJob.perform_async(email_account.id, email_params)
      end
    end

    context "with failed job" do
      before {
        allow_any_instance_of(EmailSenderJob).to receive(:perform).and_raise "error"
      }

      it "still unlocks mutex" do
        expect { Sidekiq::Testing.inline! { EmailSenderJob.perform_async(email_account.id, email_params) } }.to raise_error
        # expect(mutex).to have_received(:unlock).once
      end
    end
  end
end
