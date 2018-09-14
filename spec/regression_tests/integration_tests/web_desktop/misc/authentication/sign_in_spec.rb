require "rails_helper"

describe "the sign in page", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
  end

  context "when the email and password are correct" do
    it "should sign in the user" do
      expect(page).to have_selector("#main")
    end
  end
end
