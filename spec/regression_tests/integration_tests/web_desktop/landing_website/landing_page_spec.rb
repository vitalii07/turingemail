require "rails_helper"

describe "landing page", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }

  context "when the user is not signed in" do
    it "should have the correct links" do
      visit "/"

      expect(page).to have_link("Sign In")

      expect(current_url).to eq "http://localhost:4001/"

      expect(page).to_not have_text(user.email)
    end
  end

  context "when the user is signed in" do
    before { capybara_signin_user(user) }

    context "and when the user is signed in to a google account" do
      let(:gmail_account) { FactoryGirl.create(:gmail_account) }
      before do
        user.gmail_accounts << gmail_account
        visit '/'
      end

      it "should not have 'Sign In' link" do
        expect(page).to_not have_link("Sign In")
      end

      it "should have its gmail address in the main page" do
        expect(page).to have_text(user.current_email_account().email)
      end

      context "when click its gmail address" do

        before do
          find(".tm_user-details").click
        end

        it "should have 'Sign Out' link" do
          expect(page).to have_link('Sign Out')
        end

        context "when click 'Sign Out' link" do

          before do
            click_link("Sign Out")
          end

          it "should have 'Signed out successfully.' message" do
            expect(page).to have_text('Signed out successfully.')
          end

          it "should have 'Sign In' link" do
            expect(page).to have_link('Sign In')
          end

        end

      end

    end

    context "and when the user is not signed in to a google account" do

      it "should have the correct links" do
        visit "/"

        expect(page).to have_text("Add email accounts")

        expect(page).to_not have_link("Sign In")
      end

    end
  end

end
