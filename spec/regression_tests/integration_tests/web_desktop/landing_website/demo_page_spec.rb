require "rails_helper"

describe "demo page", type: :feature, js: true do
  before { visit "/demo" }

  it "has the right title and subtitle" do
    expect(page).to have_text("Test drive.")
    expect(page).to have_text("Tour our product in a live demo.")
  end

  it "has the demo product button" do
    expect(page).to have_button("Access Live Demo")
  end

  context "when a user is not signed in" do
    it "should have the sign in link" do
      expect(page).to have_link("Sign In")
    end
  end

  context "when a user is signed in" do
    let(:user) { FactoryGirl.create(:user) }
    before { capybara_signin_user(user) }

    it "should have the sign out link" do
      visit "/demo"

      expect(page).to have_link("Sign Out")
    end

  end

end
