require "rails_helper"

describe "compose email", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user_with_gmail_accounts) }
  let(:email_recipient) { FactoryGirl.create(:email_recipient) }

  before do
    capybara_signin_user(user)
    click_button("Compose")
  end

  context "when has no recipients" do
    it "should not allow sending" do
      click_on("Send")
      expect(page).to have_text("Email has no recipients!")
    end
  end

  context "when has recipients" do
    before { find(".to-input").set(email_recipient.person.email_address) }

    context "and has no subject" do

      it "should not allow sending" do
        click_on("Send")
        expect(page).to have_text("Email subject is not set!")
      end
    end

    context "and has a subject" do
      before { find(".subject-input").set("A subject") }

      it "should allow sending" do
        click_on("Send")
        expect(page).to have_text("Your message has been sent. Undo")
      end
    end
  end
end
