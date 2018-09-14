require "rails_helper"

describe "Create Email Template", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  before do
    capybara_signin_user(user)
    click_link("Templates")
    click_button("New Category")
  end

  context "when has no template name" do
    it "should not allow creating" do
      find(".finish-create-email-template-category-button").click
      expect(page).to have_text("Please enter a category title")
    end
  end

  context "when has valid template name" do
    before { find(".tm_template-new-category input").set("myrandcatname") }

    it "should allow creating" do
      find(".finish-create-email-template-category-button").click
      expect(page).to have_text("Category has been successfully created!")
    end
  end

  context "when has same template name" do
    before {
      click_button("New Category")
      find(".tm_template-new-category input").set("myrandcatname")
      find(".finish-create-email-template-category-button").click
      click_button("New Category")
      find(".tm_template-new-category input").set("myrandcatname")
    }

    it "should not allow creating" do
      find(".finish-create-email-template-category-button").click
      expect(page).to have_text("Category with this name already exists")
    end
  end
end