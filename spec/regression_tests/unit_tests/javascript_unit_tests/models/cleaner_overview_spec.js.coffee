describe "CleanerOverview", ->
  beforeEach ->
    @cleanerOverview = new TuringEmailApp.Models.CleanerOverview()

  it "uses '/api/v1/email_accounts/cleaner_overview' as url", ->
    expected = '/api/v1/email_accounts/cleaner_overview'
    expect( @cleanerOverview.url ).toEqual expected
