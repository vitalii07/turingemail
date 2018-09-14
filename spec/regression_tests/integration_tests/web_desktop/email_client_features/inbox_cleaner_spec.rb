require "rails_helper"

describe "Inbox Cleaner", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
  end

  context "when the Inbox Cleaner is navigated to" do
    before { click_link("Inbox Cleaner") }

    it "displays the Inbox Cleaner" do
      expect(page).to have_text("Inbox Cleaner")
      expect(page).to have_text("Inbox Cleaner will analyze your inbox and group similar emails for you to archive unwanted emails.")
    end
  end

end