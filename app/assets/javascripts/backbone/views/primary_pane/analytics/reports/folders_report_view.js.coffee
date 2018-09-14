TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics ||= {}
TuringEmailApp.Views.PrimaryPane.Analytics.Reports ||= {}

class TuringEmailApp.Views.PrimaryPane.Analytics.Reports.FoldersReportView extends  TuringEmailApp.Views.PrimaryPane.Analytics.Reports.ReportView
  template: JST["backbone/templates/primary_pane/analytics/reports/folders_report"]

  className: "report-view"

  render: ->
    chartData = @getChartData()

    @$el.html @template()

    @drawChart chartData, ".email-folders-chart", "Email Folders Share"

    @

  getChartData: ->
    data = [
      [ 'Drafts Folder', @model.get("percent_draft") ]
      [ 'Inbox Folder', @model.get("percent_inbox") ]
      [ 'Sent Folder', @model.get("percent_sent") ]
      [ 'Spam Folder', @model.get("percent_spam") ]
      [ 'Starred Folder', @model.get("percent_starred") ]
      [ 'Trash Folder', @model.get("percent_trash") ]
      # [ 'Unread Folder', @model.get("percent_unread") ]
    ]

    data.sort (a, b) ->
      return if a[1] < b[1] then 1 else -1

    return data

  drawChart: (chartData, divSelector, chartTitle) ->
    return if $(divSelector).length is 0

    @$el.find(divSelector).highcharts
      chart:
        plotBackgroundColor: null
        plotBorderWidth: null
        plotShadow: false
        backgroundColor: null
        style: fontFamily: "'Gotham SSm A', 'Gotham SSm B', 'Helvetica Neue', Helvetica, Arial, sans-serif", fontSize: "12px", fontWeight: "300"
      title:
        align: 'left'
        style: fontSize: '14px'
        text: chartTitle
      credits: enabled: false
      tooltip:
        backgroundColor: null
        borderWidth: 0
        shadow: false
        useHTML: true
        shared: true
        headerFormat: '<table><tr><td class="tooltip-text">{point.key}</td>'
        pointFormat: '<td class="tooltip-count">{point.percentage:.1f}%</td>'
        footerFormat: '</tr></table>'
      plotOptions: pie:
        innerSize: '30%'
        cursor: 'pointer'
        allowPointSelect: true
        dataLabels:
          enabled: !isMobile()
          format: '<b>{point.name}</b>: {point.percentage:.1f} %'
          style: color: Highcharts.theme and Highcharts.theme.contrastTextColor or 'black'
        showInLegend: true
      series: [{
        type: 'pie'
        name: 'Share'
        data: chartData
      }]
      legend:
        align: (if isMobile() then 'center' else 'right')
        layout: 'vertical'
        verticalAlign: (if isMobile() then 'bottom' else 'middle')
        symbolWidth: 14
        symbolHeight: 14
        symbolRadius: 7
        itemMarginTop: 3
        itemMarginBottom: 3
        itemStyle: fontWeight: 'normal'
        labelFormat: '{name}: {percentage:.1f}%'
      navigation: buttonOptions: y: -5
