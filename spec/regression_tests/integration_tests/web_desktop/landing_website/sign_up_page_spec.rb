require "rails_helper"

describe "sign up page", type: :feature, js: true do
  let(:subscription_plan) { FactoryGirl.create(:subscription_plan) }

  before do
    allow(SubscriptionPlan).to receive(:first).and_return(subscription_plan)

    visit "/users/sign_up"
  end

  it "has the right step" do
    expect(page).to have_text("Step 1 of 3")
  end

  it "has the Join the Turing network request" do
    expect(page).to have_text("Join the Turing network.")
  end

  it "has the Individual plan information" do
    expect(page).to have_text("Your Plan:")
    expect(page).to have_text("Free Trial")
    expect(page).to have_text("You are signing up for a free trial of Turing. After 14 days, your credit card will be charged $9.99 per month.")
  end

  it "has the right form elements" do
    expect(page).to have_button "Create Account"
    expect(page).to have_selector("#user_email")
    expect(page).to have_selector("#user_password")
    expect(page).to have_selector("#user_password_confirmation")
  end

  context "when a user is not signed in" do
    it "should have the sign in link" do
      expect(page).to have_link("Sign In")
    end
  end

  context "when a user is signed in" do
    let(:user) { FactoryGirl.create(:user) }
    before { capybara_signin_user(user) }

    it "redirects to /signup_accounts" do
      visit "/users/sign_up"

      expect(page).to have_text("Choose an account to connect")
    end

  end

end