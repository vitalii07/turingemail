require "rails_helper"

describe "benefits page", type: :feature, js: true do
  before { visit "/benefits" }

  it "has the right title section" do
    expect(page).to have_text("Better basics.")
  end

  it "has the right headlines for highlighted features" do
    expect(page).to have_text("Order the chaos.")
    expect(page).to have_text("Meticulous timing.")
    expect(page).to have_text("Impeccably tailored design.")
    expect(page).to have_text("The complete suite.")
  end

  it "has the demo product button" do
    expect(page).to have_link("Demo Product")
  end

  it "has the join now button" do
    expect(page).to have_link("Join Now")
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
      visit "/benefits"

      expect(page).to have_link("Sign Out")
    end

  end

end