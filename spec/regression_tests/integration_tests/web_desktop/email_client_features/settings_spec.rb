require "rails_helper"

describe "Settings", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
    click_link("Settings")
  end

  context "when open General" do
    before { click_link("General") }

    it "contains General tab" do
      expect(page).to have_selector("div#tab-1")
    end

    it "contains the Keyboard Shortcut setting" do
      expect(page).to have_text("Keyboard Shortcuts")
    end

    it "contains the Preview Panel setting" do
      expect(page).to have_text("Preview Panel")
    end

    it "contains the Inbox Tabs setting" do
      expect(page).to have_text("Inbox Tabs")
    end

    it "contains the Contact Sidebar setting" do
      expect(page).to have_text("Contact Sidebar")
    end
  end

  context "when open the Profile Settings" do
    before { click_link("Profile") }

    it "contains Profile tab" do
      expect(page).to have_selector("div#tab-2")
    end
  end

  context "when open the Desktop Settings" do
    before { click_link("Desktop") }

    it "contains Desktop tab" do
      expect(page).to have_selector("div#tab-3")
    end

    it "contains Desktop application download information" do
      expect(page).to have_text("Click here to download the Turing Desktop application for Max OS X.")
    end
  end

end