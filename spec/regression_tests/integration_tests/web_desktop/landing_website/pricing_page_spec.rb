require "rails_helper"

describe "pricing page", type: :feature, js: true do
  before { visit "/pricing" }

  it "has the Turing tagline" do
    expect(page).to have_text("Demand exemplary.")
  end

  it "has the Individual plan information" do
    expect(page).to have_text("Individual")
    expect(page).to have_text("Join our exclusive network with an Individual membership to your new modernized email.")
    expect(page).to have_text("$9.99 / month")
    expect(page).to have_text("14 day free trial.")
    expect(page).to have_text("Join Now")
  end

  it "has the Teams plan information" do
    expect(page).to have_text("Teams")
    expect(page).to have_text("No team is too small. Create a Turing Team Account with two or more users. We’ll contact you for a tailored solution.")
    expect(page).to have_text("Join Now")
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
      visit "/pricing"

      expect(page).to have_link("Sign Out")
    end

  end

end