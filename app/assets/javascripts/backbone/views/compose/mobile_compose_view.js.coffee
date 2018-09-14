class TuringEmailApp.Views.MobileComposeView extends TuringEmailApp.Views.ComposeView
  template: JST["backbone/templates/compose/_compose_form"]

  className: "tm_content tm_mobile-compose"

  events: -> _.extend {}, super(),
    "click .tm_mobile-bottom-toolbar button[type=submit]": "onMobileSendNow"

  initialize: (options) ->
    super(options)

    @app = options.app
    @primaryPaneDiv = options.primaryPaneDiv
    @mainView = options.mainView

  show: ->
    @primaryPaneDiv.html("")
    @render()
    @mainView.renderSharedToolbar "Compose"
    @primaryPaneDiv.append @$el

    $(".mobile-toolbar-compose").show().siblings().hide()

    @syncTimeout = window.setTimeout(=>
      @$(".to-input").focus()
    , 1000)
    @updateSendButtonText @sendLaterDatetime()

  hide: ->
    @app.routers.emailFoldersRouter.navigate("#inbox", trigger: true)

  onMobileSendNow: (evt) ->
    console.log "SEND clicked! Sending..."
    evt.preventDefault()
    @sendEmail()

    @hide()