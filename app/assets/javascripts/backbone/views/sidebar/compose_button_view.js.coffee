class TuringEmailApp.Views.ComposeButtonView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/sidebar/compose_button"]

  events:
    "click .load-email-template": "loadEmailTemplate"
    "click .create-email-template": "showCreateEmailTemplateDialog"

  data: -> _.extend {}, super(),
    "dynamic":
      "emailTemplates": @emailTemplates
      "newEmailTemplate": @newEmailTemplate

  initialize: (options) ->
    super(options)

    @app = options.app
    @emailTemplates = options.emailTemplates
    @newEmailTemplate = new TuringEmailApp.Models.EmailTemplate()

  render: ->
    super()

    @

  loadEmailTemplate: (evt) ->
    uid = @$(evt.currentTarget).data("uid")
    emailTemplate = @emailTemplates.get(uid)

    @app.views.composeView.prependBodyHTML(emailTemplate.get("html"))
    @app.views.composeView.show()

  showCreateEmailTemplateDialog: ->
    @app.views.mainView.templateComposeView.loadEmpty
    @app.views.mainView.templateComposeView.show()