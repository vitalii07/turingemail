TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailConversations ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailConversations.ContactInboxView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_conversations/contact_inbox"]
  className: "tm_mail-split-pane vertical-split-pane"


  events: -> _.extend {}, super(),
    "click .tm_table-mail-body tr" : "setActive"
    "change .conversation-search" : "searchContacts"

  data: ->
    res = _.extend {}, super(),
      "dynamic":
        "emailConversations": @collection
        "escapeHTML": escapeHTML

    _.extend(
      res["dynamic"],
      _.pick(
        TuringEmailApp.Models.EmailGroup.prototype,
        "numEmailsText",
        "fromPreview",
        "subjectPreview",
        "datePreview",
        "hasAttachment"
      )
    )

    res


  initialize: (options)->
    super(options)

    _.extend(
      @,
      _.pick(
        TuringEmailApp.Views.ComposeView.prototype,
        "subjectWithPrefixFromEmail"
      )
    )

    @app = options.app
    @collection = new TuringEmailApp.Collections.EmailConversationsCollection

    @listenTo @collection, "add remove reset destroy", @setActive


  render: ->
    super()

    @$("[data-toggle=tooltip]").tooltip()
    @collection.fetch "success": => @setupInfiniteScroll()

    @conversationView =
      new TuringEmailApp.Views.PrimaryPane.EmailConversations.ShowView
        app: @app
        el: @$(".tm_contact-inbox-thread")
    @conversationView.render()

    @composeView =
      new TuringEmailApp.Views.PrimaryPane.EmailConversations.ComposeView
        "el": @$(".tm_contact-inbox-compose")
    @composeView.render()
    @listenTo @composeView, "emailSent", @onEmailSent

    @


  onEmailSent: (email) ->
    email.set
      "date"         : new Date
      "from_address" : TuringEmailApp.currentEmailAddress()
    @conversationView.emails.add email


  setActive: (evt) ->
    changed = true
    conversationId = $(evt?.currentTarget).attr("data-conversation-id") - 0
    if $(evt?.currentTarget).hasClass("conversation-search-container")
    	$(evt?.currentTarget).addClass("active")

    if conversationId && (@activeEmailConversation?.id != conversationId)
      @activeEmailConversation = @collection.get(conversationId)
    else if !@activeEmailConversation
      @activeEmailConversation = @collection.at(0)
    else
      changed = false

    if @activeEmailConversation && changed
      @ractive.set
        "activeEmailConversation": @activeEmailConversation

      @conversationView.page = 1
      @conversationView.removeListeners()
      @conversationView.emails.reset()
      @conversationView.model = @activeEmailConversation
      @conversationView.setEmails()
      @conversationView.setPeople()

      @composeView.model.set
        "tos"     : @composeTo()
        "subject" : @composeSubject()

      @activeEmailConversation.fetch "success": =>
        @conversationView.setEmails()
        @conversationView.setupScroll()
        @composeView.model.set "subject" : @composeSubject()
      @$(".tm_contact-inbox .tm_empty-pane").html ""


  composeTo: ->
    @activeEmailConversation.get("people")[0]?["email_address"]


  composeSubject: ->
    emails = @conversationView.emails
    email = _.last(emails.where("from_address" : @composeTo())) || emails.last()

    @subjectWithPrefixFromEmail(email?.toJSON() || {}, "Re: ")


  setupInfiniteScroll: ->
    @infiniteScrollTriggerable = true unless @infiniteScrollTriggerable
    @$(".email-threads-list-view").scroll =>
      emailThreadsListView = $(".email-threads-list-view")
      if @infiniteScrollTriggerable
        if emailThreadsListView.scrollTop() + emailThreadsListView.height() > emailThreadsListView.get(0).scrollHeight - 50
          @infiniteScrollTriggerable = false
          @collection.page += 1
          @collection.fetch "success": => @infiniteScrollTriggerable = false

      if emailThreadsListView.scrollTop() + emailThreadsListView.height() < emailThreadsListView.get(0).scrollHeight - 250
        @infiniteScrollTriggerable = true


  setupSplitPane: ->
    @splitPaneLayout = @$el.layout({
      applyDefaultStyles: false,
      resizable: true,
      closable: false,
      resizerDragOpacity: 0,
      livePaneResizing: true,
      showDebugMessages: true,
      spacing_open: 1,
      spacing_closed: 1,
      east__minSize: 300,
      south__minSize: 100,
      east__size: if @splitPaneLayout? then @splitPaneLayout.state.east.size else 0.75,
      south__size: if @splitPaneLayout? then @splitPaneLayout.state.south.size else 0.5
    })


  searchContacts: (evt) ->
    @$(".tm_contact-inbox .tm_empty-pane").html "<div class='loader'><div class='line-spin-fade-loader'><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div></div><div class='tm_empty-pane'>Now Searching...</div>"
    @collection.page = 1
    @collection.search_query = $(evt?.currentTarget).val()
    @collection.reset()
    @collection.fetch "success": (model, response, options) =>
      searchtotal = response.length
      @$(".tm_contact-inbox .tm_empty-pane").html "<div>Your search is complete.<br /><small>" + searchtotal + " conversation#{if searchtotal > 1 then 's' else ''} Found</small></div>"
      @$(".tm_mail-box-scroll.email-threads-list-view .tm_empty-pane").html "No results found."
      @$(".tm_contact-inbox-email.tm_contact-inbox-email-in").hide()
