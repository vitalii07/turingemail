describe "CleanerReport", ->
  beforeEach ->
    @cleanerReport = new TuringEmailApp.Models.CleanerReport()

  it "uses '/api/v1/email_accounts/cleaner_report' as url", ->
    expected = '/api/v1/email_accounts/cleaner_report'
    expect( @cleanerReport.url ).toEqual expected
