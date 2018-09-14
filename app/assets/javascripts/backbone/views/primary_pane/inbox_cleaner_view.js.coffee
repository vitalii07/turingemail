TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.InboxCleanerView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/inbox_cleaner"]
  className: "tm_content tm_inbox-cleaner-view"


  data: -> _.extend {}, super(),
    "dynamic" :
      "cleanerOverview" : @model


  events: -> _.extend {}, super(),
    "click .tm_button-cleaner" : "createReport"


  createReport: ->
    TuringEmailApp.showInboxCleanerReport()
