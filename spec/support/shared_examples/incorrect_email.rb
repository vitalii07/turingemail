shared_examples 'incorrect email' do
  it 'should return alert' do
    expect(page).to have_text('Email has no recipients!')
  end
end