require "rails_helper"

describe "invalid input sign in", type: :feature, js: true do

  it "should have the sign in link" do
    visit "/"
    expect(page).to have_link("Sign In")
  end

  context "when visit sign in page" do

    before do
      visit "/users/sign_in"
    end

    it "should has the right text" do
      expect(page).to have_text("Account Sign In")
      expect(page).to have_text("Welcome Back.")
    end

    it "should has user_email input" do
      expect(page).to have_selector("#user_email")
    end

    it "should has user_password input" do
      expect(page).to have_selector("#user_password")
    end

    it "should has 'Sign in to Turing' button" do
      expect(page).to have_button "Sign in to Turing"
    end

    context "when sign in with a existing user" do

      let(:user) { FactoryGirl.create(:user) }

      before do
        find("#user_email").set(user.email)
      end

      it "should have 'Invalid email or password.' message with invalid password" do
        find("#user_password").set("invalidpassword")
        click_button "Sign in to Turing"
        expect(page).to have_text("Invalid email or password.")
      end

      it "should have 'Invalid email or password.' message with blank password" do
        click_button "Sign in to Turing"
        expect(page).to have_text("Invalid email or password.")
      end

    end

    context "when sign in with a unexisting user" do

      let(:user) { FactoryGirl.create(:user) }

      it "should have 'Invalid email or password.' message with unexisting email" do
        find("#user_email").set("invalid@invalid.com")
        find("#user_password").set("invalidpassword")
        click_button "Sign in to Turing"
        expect(page).to have_text("Invalid email or password.")
      end

    end

  end

end