require "rails_helper"

describe "waitlist page", type: :feature, js: true do
  let(:user) { FactoryGirl.create(:user) }
  let(:email) { 'chuck@norris.com' }

  before do
    visit '/waitlist'
  end

  it 'should create new entry' do
    expect(page).to have_text('Turing currently has a wait list. We will notify you as soon as your position opens.')
    fill_in 'waitlist_user_email', with: email
    # page.find(".dropdown-button").click
    # page.find("ul.dropdown-menu").find("li:nth-child(1)").click
    click_button 'Notify'
    expect(page).to have_text 'You have been added to the wait list.'
    expect(WaitlistUser.first.email).to eq email
  end

  it 'should not create with wrong email' do
    # page.find(".dropdown-button").click
    # page.find("ul.dropdown-menu").find("li:nth-child(1)").click
    click_button 'Notify'
    expect(page).to have_text 'Email is invalid'
  end
end
