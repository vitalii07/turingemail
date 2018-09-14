require "rails_helper"

describe "signup accounts page", type: :feature, js: true do
  before { visit "/signup_accounts" }

  context "when a user is not signed in" do
    it "should have the sign in link" do
      expect(page).to have_link("Sign In")
    end
  end

  context "when a user is signed in" do
    let(:user) { FactoryGirl.create(:user) }
    before { capybara_signin_user(user) }
    before { visit "/signup_accounts" }

    it "should have the sign out link" do
      expect(page).to have_link("Sign Out")
    end

    it "has the right step" do
      expect(page).to have_text("Step 3 of 3")
    end

    it "has right page title and subtext" do
      expect(page).to have_text("Add email accounts.")
      expect(page).to have_text("Turing Email supports email providers including Google Apps, Outlook, Yahoo Mail, iCloud Mail, and AOL Mail. Your username will be the only account you needed for log in to access all your email accounts.")
    end

    it "has the Add Gmail account button" do
      expect(page).to have_link("Add Gmail account")
    end

    it "has the Add Outlook account button" do
      expect(page).to have_link("Add Outlook account")
    end

    it "has the Add Yahoo Mail account button" do
      expect(page).to have_link("Add Yahoo Mail account")
    end

    context "and when the user has an email account" do
      let(:gmail_account) { FactoryGirl.create(:gmail_account) }
      before do
        user.gmail_accounts << gmail_account

        visit "/signup_accounts"
      end

      it "should have the correct links" do
        expect(page).to have_text("Email Account 1")
        expect(page).to have_text(user.current_email_account().email)
      end

      it "has the Take Me to Turing button" do
        expect(page).to have_selector(".button.button-main.button-big")
      end

    end

    context "and when the user does not have an email account" do

      it "does not have the Take Me to Turing button" do
        expect(page).to_not have_selector(".button.button-main.button-big")
      end

    end

  end

end
