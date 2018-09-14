TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.InboxCleanerReportView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/inbox_cleaner_report"]
  className: "tm_content tm_inbox-cleaner-view"


  data: -> _.extend {}, super(),
    "dynamic" :
      "cleanerReport" : @model


  events: -> _.extend {}, super(),
    "click .tm_button-submit"            : "autoFile"
    "click #archive-before-date button"  : "showCalendar"
    "click #archive-from-address button" : "resetAddress"


  initialize: (options) ->
    super(options)
    @app = options.app


  render: ->
    super()

    @reportInterval = window.setInterval(
      (=>
        if @model.isFinished()
          window.clearInterval(@reportInterval)
          composeViewCls = TuringEmailApp.Views.ComposeView
          @$(".datetimepicker").datetimepicker
            format: composeViewCls.dateFormat
            formatTime: "g:i a"

          composeViewCls.prototype.setupEmailAddressAutocomplete.call(
            @ ,
            "#archive-from-address input"
          )
        else
          @model.fetch()
      ),
      2000
    )

    @


  showCalendar: ->
    @$("#archive-before-date input").datetimepicker("show")


  resetAddress: ->
    @model.unset "from_address"


  remove: ->
    window.clearInterval(@reportInterval)
    super()


  autoFile: (evt) ->
    $btn = $ evt.currentTarget
    $btn.attr "disabled", ""
    $btn.text "Archived"

    @app.showAlert("Inbox cleaner archive action is now being taken.", "alert-success", 5000)

    @model.set("category", $btn.data("category"))
    @model.save()


