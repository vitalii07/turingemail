shared_context 'email scheduling' do
  before do
    capybara_signin_user(user)
    click_link('Scheduled')
  end
end

shared_context 'with_existing_entities' do
  before do
    @delayed_emails = FactoryGirl.create_list(:delayed_email, 10,
      email_account: user.current_email_account,
      tos: ['t1@t1.com', 't2@t2.com'],
      bccs: ['b1@t1.com', 'b2@t2.com'],
      ccs: ['c1@t1.com', 'c2@t2.com']
    )
  end
end