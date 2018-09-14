TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailRemindersView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/email_reminders"]

  className: "tm_content"

  initialize: (options) ->
    super(options)

  render: ->
    @$el.html(@template())

    @$("[data-toggle=tooltip]").tooltip
      container: "body"

    @$(".tm_email-reminder-dropdown").click (e) ->
      e.stopPropagation()

    @$(".tm_email-reminder-slider").slider
      animate: true
      step: 20

    @