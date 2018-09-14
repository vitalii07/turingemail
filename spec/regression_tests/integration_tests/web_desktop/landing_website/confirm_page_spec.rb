require "rails_helper"

describe "confirm page", type: :feature, js: true do
  before { visit "/confirm" }

  it "has the confirmed text" do
    expect(page).to have_text("Confirmed.")
  end

  it "has the wait list text" do
    expect(page).to have_text("You have been added to the wait list.")
  end

  it "has the demo Turing button" do
    expect(page).to have_link("Demo Turing")
  end

  it "has the Turing Features button" do
    expect(page).to have_link("Turing Features")
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
      visit "/confirm"

      expect(page).to have_link("Sign Out")
    end

  end

end