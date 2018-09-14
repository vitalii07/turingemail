require "rails_helper"

describe "mobile demo page", type: :feature, js: true do
  before do
    resize_window_to_iphone_5_mobile_portrait
    visit "/demo"
  end

  after do
    resize_window_default
  end

  it "has the right title and subtitle" do
    expect(page).to have_text("Test drive.")
    expect(page).to have_text("Tour our product in a live demo.")
  end

  it "has the demo product button" do
    expect(page).to have_button("Access Live Demo")
  end

end
