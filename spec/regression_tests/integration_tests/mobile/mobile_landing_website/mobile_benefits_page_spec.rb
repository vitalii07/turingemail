require "rails_helper"

describe "mobile benefits page", type: :feature, js: true do
  before do
    resize_window_to_iphone_5_mobile_portrait
    visit "/benefits"
  end

  after do
    resize_window_default
  end

  describe "by default" do

    it "has the right title section" do
      expect(page).to have_text("Better basics.")
    end

    it "has the right subtext" do
      expect(page).to have_text("Today’s communication style is constant and continuous. Every technology—device or network—we connect through has adapted to these modern conditions. Except email. Now, Turing email brings your familiar email interface alongside the modern messaging experience. Access your regular inbox, or a separate dynamic Conversations feature that displays emails like instant message threads: continuous, contact-sorted, and content only. Email capability has finally evolved to match modern demands.")
    end

  end

end