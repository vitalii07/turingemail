TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailConversations ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailConversations.ShowView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_conversations/show"]

  events:
    "click .email_forward_button": "onForwardEmail"
    "click .email_delete_button": "onDeleteEmail"


  data: ->
    res = _.extend {}, super(),
      "dynamic":
        "userAddress": TuringEmailApp.collections.emailAccounts.current_email_account
        "user": TuringEmailApp.models.user
        "emails": @emails
        "people": @people

    _.extend(
      res["dynamic"],
      _.pick(
        TuringEmailApp.Models.EmailGroup.prototype,
        "fromPreview",
        "datePreview",
      )
    )

    res


  initialize: (options)->
    super(options)

    @people            = new Backbone.Collection

    @emails            = new Backbone.Collection
    @emails.model      = TuringEmailApp.Models.UidModel
    @emails.comparator = (a, b) -> a.get("date") - b.get("date")

    @app = options.app


  setEmails: ->
    @emails.set @model.get("emails"), "remove": false


  setPeople: ->
    @people.set @model.get("people")


  scrollToEmail: (uid) ->
    if uid
      $email = $("[data-uid='#{uid}']")
    else
      $email = $(".tm_contact-inbox-email").last()

    @$el.scrollTop(@$el.scrollTop() + $email.position()?.top)


  setListeners: ->
    @listenTo @emails, "add", =>
      window.setTimeout =>
        @scrollToEmail() if @applyCallbacks

    @$el.on "scroll.conversation", =>
      if @applyCallbacks
        $email = @$(".tm_contact-inbox-email").first()
        uid = $email.attr "data-uid"
        if ((@$el.scrollTop() < $email.position()?.top) &&
            (@model.get("emails_count") > @emails.length))
          @model.page += 1
          @removeListeners()
          @model.fetch "success": =>
            @setEmails()
            @scrollToEmail uid
            @setListeners()
    @applyCallbacks = true


  removeListeners: ->
    @stopListening @emails, "add"
    @$el.off "scroll.conversation"
    @applyCallbacks = false


  setupScroll: ->
    @removeListeners()
    @scrollToEmail()
    @setListeners()


  onForwardEmail: (evt) ->
    emailUID = $(evt.currentTarget).closest(".tm_contact-inbox-email").data("uid")
    email = @emails.get emailUID
    emailJSON = email.toJSON()

    @app.showEmailEditorWithEmail emailJSON, "forward"

  onDeleteEmail: (evt) ->
    emailUID = $(evt.currentTarget).closest(".tm_contact-inbox-email").data("uid")
    email = @emails.get emailUID
