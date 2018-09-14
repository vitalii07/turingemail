require "rails_helper"

describe "mobile confirm page", type: :feature, js: true do
  before do
    resize_window_to_iphone_5_mobile_portrait
    visit "/confirm"
  end

  after do
    resize_window_default
  end

  it "has the confirmed text" do
    expect(page).to have_text("Confirmed.")
  end

  it "has the wait list text" do
    expect(page).to have_text("You have been added to the wait list.")
  end

end