TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.AnalyticsView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/analytics/analytics"]

  className: "tm_content tm_analytics-view"

  initialize: ->
    @reports =
      ".contacts_report":
        modelClass: TuringEmailApp.Models.Reports.ContactsReport
        viewClass: TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ContactsReportView

      ".threads_report":
        modelClass: TuringEmailApp.Models.Reports.ThreadsReport
        viewClass: TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ThreadsReportView

      ".email_volume_report":
        modelClass: TuringEmailApp.Models.Reports.EmailVolumeReport
        viewClass: TuringEmailApp.Views.PrimaryPane.Analytics.Reports.EmailVolumeReportView

      ".lists_report":
        modelClass: TuringEmailApp.Models.Reports.ListsReport
        viewClass: TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ListsReportView

      ".folders_report":
        modelClass: TuringEmailApp.Models.Reports.FoldersReport
        viewClass: TuringEmailApp.Views.PrimaryPane.Analytics.Reports.FoldersReportView

      ".attachments_report":
        modelClass: TuringEmailApp.Models.Reports.AttachmentsReport
        viewClass: TuringEmailApp.Views.PrimaryPane.Analytics.Reports.AttachmentsReportView

      # ".geo_report":
      #   modelClass: TuringEmailApp.Models.Reports.GeoReport
      #   viewClass: TuringEmailApp.Views.PrimaryPane.Analytics.Reports.GeoReportView

    Highcharts.setOptions
      colors: ['#0099FF', '#DA4453', '#967ADC', '#3BAFDA', '#AAB2BD', '#D770AD', '#37BC9B', '#8CC152', '#E9573F', '#F6BB42', '#434A54']

  render: ->
    @$el.html(@template())

    for reportSelector, reportAttrs of @reports
      reportModel = new reportAttrs.modelClass()
      reportAttrs.view = new reportAttrs.viewClass(
        model: reportModel
        el: @$el.find(reportSelector)
      )

    @$el.attr("name", "tm_analytics-view")
    @hideLoadingIcon()

    # Reflow charts after tab switch
    @$el.on 'shown.bs.tab', 'a[data-toggle="tab"]', (evt) =>
      tabSelector = evt.currentTarget.dataset.target

      if @$(tabSelector).is(":empty")
        # Show loading icon
        @showLoadingIcon()
        @reports[tabSelector].view.model.fetch
          success: (=>
            @hideLoadingIcon()
            @$(tabSelector).find(".tm_charts").children().each ->
              $(@).highcharts()?.reflow())
          error: (=>
            @hideLoadingIcon()
          )
      else
        @$(tabSelector).find(".tm_charts").children().each ->
          $(@).highcharts()?.reflow()

    # Show attachments report tab
    tabToShow = ".contacts_report"
    @$el.find("a[data-target=\"#{tabToShow}\"]").tab 'show'
    @$el.find(tabToShow).addClass 'active'

    @

  showLoadingIcon: ->
    @$el.find(".tm_settings-tab-loading").show()

  hideLoadingIcon: ->
    @$el.find(".tm_settings-tab-loading").hide()