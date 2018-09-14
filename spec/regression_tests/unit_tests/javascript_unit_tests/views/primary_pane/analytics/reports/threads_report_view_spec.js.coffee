describe "ThreadsReportView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @threadsReport = new TuringEmailApp.Models.Reports.ThreadsReport()

    @threadsReportView = new TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ThreadsReportView(
      model: @threadsReport
    )

    threadsReportFixtures = fixture.load("reports/threads_report.fixture.json", true);
    @threadsReportFixture = threadsReportFixtures[0]

    @server = sinon.fakeServer.create()
    @server.respondWith "GET", new TuringEmailApp.Models.Reports.ThreadsReport().url, JSON.stringify(@threadsReportFixture)

  afterEach ->
    @server.restore()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@threadsReportView.template).toEqual JST["backbone/templates/primary_pane/analytics/reports/threads_report"]

  describe "#render", ->
    beforeEach ->
      @threadsReport.fetch()
      @server.respond()

    it "renders the report", ->
      expect(@threadsReportView.$el).toContainHtml("Threads")

    it "renders the top email threads", ->
      expect(@threadsReportView.$el).toContainHtml('Top Email Threads')

      for emailThread, index in @threadsReport.get("top_email_threads")
        expect(@threadsReportView.$el).toContainHtml('<td><a href="#email_thread/' + emailThread.uid + '">' +
                                                   emailThread.email_subject + '</a></td>')
