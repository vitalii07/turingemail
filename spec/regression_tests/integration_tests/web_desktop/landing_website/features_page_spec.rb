require "rails_helper"

describe "features page", type: :feature, js: true do
  before { visit "/features" }

  it "has the right title section" do
    expect(page).to have_text("Features")
    expect(page).to have_text("Tailored features for your working needs.")
  end

  it "has the collections" do
    expect(page).to have_text("Fundamentals")
    expect(page).to have_text("Core")
    expect(page).to have_text("for Sales")
    expect(page).to have_text("for Customer Service")
  end

  context "by default" do

    it "shows the fundamentals collection" do
      expect(page).to have_text("We’ve built our features on a few behind-the-scenes fundamentals to provide an exceptional email experience for every Turing customer.")

      expect(page).to have_text("A constantly updating inbox.")
      expect(page).to have_text("One username to manage all accounts.")
      expect(page).to have_text("Access from any device.")
      expect(page).to have_text("Exceptionally fast user experience.")
      expect(page).to have_text("A digital fortress of email security.")
      expect(page).to have_text("Innovative and cutting edge technology.")
    end

    it "has the Select the Individual Plan button" do
      expect(page).to have_selector("#tab-1 .button.button-big.button-main")
    end

    context "when a user clicks on the Select the Individual Plan button" do
      before { find("#tab-1 .button.button-big.button-main").click }

      it "goes to the pricing page" do
        expect(page).to have_text("Demand exemplary.")
      end

    end

  end

  context "when the Core collection is selected" do
    before { find('a[href="#tab-2"]').click }

    it "shows the Core collection" do
      expect(page).to have_text("Email should be easy, it should be fluid, it should be intuitive and helpful. Every Turing feature is with built for these necessities to help you accomplish more than you thought possible.")

      expect(page).to have_text("View emails like message threads.")
      expect(page).to have_text("Snooze the ill timed.")
      expect(page).to have_text("View all inbox attachments in a single scrollable list.")
      expect(page).to have_text("Swiftly archive unwanted emails.")
      expect(page).to have_text("Manage all subscriptions from one page.")
      expect(page).to have_text("Pull back a sent email.")
    end

    it "has the Select the Individual Plan button" do
      expect(page).to have_selector("#tab-2 .button.button-big.button-main")
    end

    context "when a user clicks on the Select the Individual Plan button" do
      before { find("#tab-2 .button.button-big.button-main").click }

      it "goes to the pricing page" do
        expect(page).to have_text("Demand exemplary.")
      end

    end

  end

  context "when the Core collection is selected" do
    before { find('a[href="#tab-3"]').click }

    it "shows the Core collection" do
      expect(page).to have_text("Your job is about relationships—initiating, building, maintaining. Our key features will help you and your team connect more efficiently with your leads and close more deals.")

      expect(page).to have_text("Connect on time with scheduled emails.")
      expect(page).to have_text("Confirm your email was opened.")
      expect(page).to have_text("Know when a lead hasn’t responded.")
      expect(page).to have_text("Salesforce integration (coming next).")
      expect(page).to have_text("Learn details about your leads.")
      expect(page).to have_text("Manage your email time more efficiently.")
    end

    it "has the Select the Individual Plan button" do
      expect(page).to have_selector("#tab-3 .button.button-big.button-main")
    end

    context "when a user clicks on the Select the Individual Plan button" do
      before { find("#tab-3 .button.button-big.button-main").click }

      it "goes to the pricing page" do
        expect(page).to have_text("Demand exemplary.")
      end

    end

  end

  context "when the Core collection is selected" do
    before { find('a[href="#tab-4"]').click }

    it "shows the Core collection" do
      expect(page).to have_text("Your job is to solve problems, ease concerns, and make your customers feel valued. We help you and your team stay organized, consistent and provide fast follow up.")

      expect(page).to have_text("Know when to check in.")
      expect(page).to have_text("Simplify response time to common inquiries.")
      expect(page).to have_text("Provide personalized attention.")
      expect(page).to have_text("Learn your customer.")
      expect(page).to have_text("Provide timely follow up.")
      expect(page).to have_text("Zendesk Integration (coming next).")
    end

    it "has the Select the Individual Plan button" do
      expect(page).to have_selector("#tab-4 .button.button-big.button-main")
    end

    context "when a user clicks on the Select the Individual Plan button" do
      before { find("#tab-4 .button.button-big.button-main").click }

      it "goes to the pricing page" do
        expect(page).to have_text("Demand exemplary.")
      end

    end

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
      visit "/features"

      expect(page).to have_link("Sign Out")
    end

  end

end
