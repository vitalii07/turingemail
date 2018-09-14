TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailConversations ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailConversations.ComposeView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_conversations/compose"]


  events: -> _.extend {}, super(),
    "submit" : "sendEmail"


  data: -> _.extend {}, super(),
    "dynamic" :
      "email" : @model
    "computed" :
      "email._html_part" :
        "get" : "${_}.replace(\"<br>\", \"\\n\")"
        "set" : (val) -> val.replace("\n", "<br>")


  initialize: ->
    super()

    @newEmail()


  newEmail: ->
    @model = new TuringEmailApp.Models.Email
    @ractive?.set "email", @model


  sendEmail: ->
    @model.sendEmail().done( =>
      @trigger "emailSent", @model
      @newEmail()
    ).fail( =>
      TuringEmailApp.showAlert("There was an error in sending your email",
                               "alert-error",
                               5000)
    )
