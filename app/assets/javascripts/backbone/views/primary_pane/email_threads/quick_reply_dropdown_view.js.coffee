TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailThreads ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailThreads.QuickReplyView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/email_threads/quick_reply_dropdown"]

  initialize: (options) ->
    super(options)

    @emailThreadView = options.emailThreadView
    @app = options.app

  render: ->
    @$el.after(@template())

    @$el.parent().find(".quick-reply-option").click (evt) =>
      evt.preventDefault()
      @emailThreadView.trigger("replyClicked", @emailThreadView)
      @app.views.composeView.$el.find(".tm_compose-body .redactor-editor").prepend($(evt.target).text() + "<br /><br /> - Sent with Turing Quick Response.")
      @app.views.composeView.$el.find(".compose-modal button.main-send-button").click()

    @
