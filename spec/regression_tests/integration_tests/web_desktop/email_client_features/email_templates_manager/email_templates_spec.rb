require "rails_helper"

describe "Email Templates", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
  end

  context "when clicked" do
    it "should contain Email Templates" do
      click_link("Templates")
      expect(page).to have_text("Templates")
    end
  end

end