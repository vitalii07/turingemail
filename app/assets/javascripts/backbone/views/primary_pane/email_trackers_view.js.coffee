TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailTrackersView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_trackers"]
  className: "tm_content"

  events:
    "click a[data-sort-by]": "sort"
    "click .tm_search-field-buttons .tm_search-filter-submit": "filter"
    "click .tm_search-field-buttons .tm_search-filter-reset": "resetFilter"

  initialize: (options) ->
    super(options)

    @app = options.app
    @sortFields =
      "sent": "Sent"
      "date": "Date"
      "subject": "Subject"
    @sortField = "sent"
    @filterKeyword = ""

    @listenTo(@collection, "reset", @render)

  data: -> _.extend {}, super(),
    "dynamic":
      "sortFields": @sortFields
      "sortField": @sortField
      "filterKeyword": @filterKeyword
      "getViewCountOfRecipients": (recipients) ->
        _.reduce recipients, ((viewCount, recipient) ->
          viewCount + recipient.email_tracker_views.length
        ), 0

  render: ->
    super()

    # TODO: We have to decide to use server side or client side filtering
    # Now it is using client-side filtering
    @filteredCollection = @collection.filterBy(@filterKeyword)

    # TODO: We have to decide to use server side or client side sorting
    # Now it is using client-side sorting
    @filteredCollection.sortByField(@sortField)

    @ractive.set
      "emailTrackers": @filteredCollection

    @setupFilterBox()

    chartData = @formatChartData @collection.toJSON()

    @drawChart chartData

    setTimeout (=>
      @$el.find('.email-tracker-chart').highcharts().reflow()
      @drawChart chartData
    ), 200

  setupFilterBox: ->
    @$('.tm_search-filter-keyword').on("keypress", (e) =>
      if (e.keyCode == 13)
        @filter()
        return false
    )

  formatChartData: (emailTrackersJSON) ->
    months = ['Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun', 'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec']
    sent = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]
    opens = [0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0]

    # Calculate sent and opens
    for emailTracker in emailTrackersJSON
      emailDate = new Date(emailTracker["email_date"])
      sent[emailDate.getMonth()] += 1
      for emailTrackerRecipient in emailTracker["email_tracker_recipients"]
        for emailTrackerView in emailTrackerRecipient["email_tracker_views"]
          emailOpenDate = new Date(emailTrackerView["created_at"])
          opens[emailOpenDate.getMonth()] += 1
          if emailOpenDate.getMonth()
            opens = []
    
    if emailDate == undefined
      sent = []
    if emailOpenDate == undefined
      opens = []

    chartData =
      months: months
      sent: sent
      opens: opens

  drawChart: (chartData) ->
    @$el.find('.email-tracker-chart').highcharts
      chart:
        type: 'column'
        backgroundColor: null
        reflow: true
        style:
          fontFamily: "'Gotham SSm A', 'Gotham SSm B', 'Helvetica Neue', Helvetica, Arial, sans-serif", fontSize: "12px", fontWeight: "300"
      title:
        text: 'Emails Sent & Opened by month'
      credits:
        enabled: false
      exporting:
        enabled: false
      tooltip:
        shadow: false
      plotOptions:
        bar:
          dataLabels:
            enabled: true
      xAxis:
        title:
          text: null
        categories: chartData.months
      yAxis: [{
        min: 0
        title:
          text: null
      }, {
        min: 0
        opposite: true
        title:
          text: null
      }]
      series: [{
        yAxis: 0
        name: 'Sent'
        data: chartData.sent
      }, {
        yAxis: 0
        name: 'Opens'
        data: chartData.opens
      }]
      lang:
      	noData: 'You have no tracked emails.'
      noData:
        style: {
          color: '#CCCCCC',
          fontSize: '17px'
          fontWeight: '300'
        }
    @$el.find('.email-tracker-chart').highcharts().reflow()

  sort: (evt) ->
    @selectedSortField = $(evt.currentTarget).data("sort-by")
    if @selectedSortField != @sortField
      @sortField = @selectedSortField
      @render()

  filter: (evt) ->
    @filterKeyword = @ractive.get("filterKeyword")
    @render()

  resetFilter: (evt) ->
    @filterKeyword = ""
    @ractive.set
      "filterKeyword": @filterKeyword

    @render()
