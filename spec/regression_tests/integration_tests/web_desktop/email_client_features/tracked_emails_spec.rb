require "rails_helper"

describe "Tracked Emails", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
  end

  context "when clicked" do
    it "should contain Tracked Emails" do
      click_link("Tracked")
      expect(page).to have_text("Tracked Emails")
    end
  end

end