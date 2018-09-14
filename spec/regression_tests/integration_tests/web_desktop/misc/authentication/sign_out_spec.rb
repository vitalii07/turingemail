require "rails_helper"

describe "sign out", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
  end

  context "by default following sign in" do

    it "should sign in the user" do
      expect(page).to have_selector("#main")
    end

  end

  context "when the user clicks sign out" do
    before do
      find(".tm_user-details").click
      click_link("Sign Out")
    end

    it "should sign out the user and redirect them to the landing page" do
      expect(page).to have_link("Sign In")

      expect(current_url).to eq "http://localhost:4001/"

      expect(page).to_not have_text(user.email)

      expect(page).to_not have_selector("#main")
    end

  end

end
