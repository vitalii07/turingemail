TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailThreads ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailThreads.EmailThreadView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_threads/email_thread"]

  className: "tm_mail-thread"

  events:
    "click .email-collapse-expand": "toggleExpandEmail"
    "click .more-link": "expandContactsText"
    "click .less-link": "collapseContactsText"

  initialize: (options) ->
    super(options)

    @app = options.app
    @uploadAttachmentPostJSON = options.uploadAttachmentPostJSON
    @emailTemplatesJSON = options.emailTemplatesJSON

    @emails            = new Backbone.Collection
    @emails.model      = TuringEmailApp.Models.UidModel
    @emails.comparator = (a, b) -> a.get("date") - b.get("date")

    @rendering = false
    @emailAddresses = null
    @sidebarCollapsed = false
    @currentEmailUID = null
    @threadPreviewData = null
    @meAddress = @app.currentEmailAddress()
    @contactsTextWrapperWidth = null
    @contactsFontSize = 11

    @listenTo(@app.views.mainView, "resize:emailThreadPane", @calcContactsTextOfEmails)

  data: -> _.extend {}, super(),
    "dynamic":
      "rendering": @rendering
      "isSplitPaneMode": @app.isSplitPaneMode()
      "profilePicture": @app.models.user.get("profile_picture")
      "contextSidebarEnabled": @app.models.userConfiguration.get("context_sidebar_enabled")
      "isMobile": isMobile()
      "sidebarCollapsed": @sidebarCollapsed
      "emailThread": @model
      "threadPreviewData": @threadPreviewData
      "emails": @emails
      "currentEmailUID": @currentEmailUID
      "meAddress": @meAddress

  render: ->
    super()

    return if @rendering

    if @model
      @seenChanging = @model._changing && @model.changed.seen?
      @rendering = true
      @ractive.set rendering: @rendering

      force =
        ((@emails.length < @model.get("emails_count")) &&
         (@emails.length < (@model.page * 25)))

      @model.load(
        success: =>
          @rendering = false

          # Set seen
          @model.setSeen(true) if not @seenChanging

          # Get preview data of email thread
          @threadPreviewData = @getPreviewDataOfEmailThread(@model)

          # Add preview data to emails
          @emails.set(@model.get("emails"), {"remove": false})
          @addDataToEmails()

          @ractive.set
            "rendering": @rendering
            "threadPreviewData": @threadPreviewData

          @setupSidebar()
          @setupScroll()
          @renderDrafts()
          @setupButtons()
          # @setupQuickReplyButton()
          @setupHoverPreviews()
          @expandAndMoveToLatestUnreadEmail()

          $(".mobile-toolbar-thread").show().siblings().hide()

          @setupLinks()
          @setupAttachmentLinks()
          @calcContactsTextOfEmails()
          @renderRfc2392InlineImages()

          @resolveTwitterEmailRenderingEdgeCase()

          @rendering = false

        error: =>
          @rendering = false
          @ractive.set rendering: @rendering
        ,
          force
      )
    else
      @$el.empty()

    @

  getPreviewDataOfEmailThread: (emailThread) ->
    threadPreviewData = {
      fromPreview: emailThread.fromPreview()
      subjectPreview: emailThread.subjectPreview()
      datePreview: emailThread.datePreview()
    }

    return threadPreviewData

  getContactsOfEmail: (email) ->
    contacts = {
      tos: email.get("tos")
      ccs: email.get("ccs")
      bccs: email.get("bccs")
    }

    contacts = _.object(_.map contacts, (contactStr, key) ->
      if contactStr?
        contactArray = contactStr.split ";"
        contactArray = _.map contactArray, (contact) ->
          return contact.trim()

        return [key, contactArray]
      else
        return [key, []]
    )


  addDataToEmails: () ->
    @emails.forEach (email, index) =>
      contacts = @getContactsOfEmail(email)

      email.set
        datePreview: TuringEmailApp.Models.Email.localDateString(email.get("date"))
        fromPreview: email.get("from_name") ? email.get("from_address")
        contacts: contacts
        contactsTextCollapsed: true


  #####################
  ### Contacts Text ###
  #####################

  # Calculate word dimensions for given text using HTML elements.
  # Optionally classes can be added to calculate with
  # a specific style / layout.
  #
  # @param {String} text The word for which you would like to know the
  #   dimensions.
  # @param {Number} font-size
  # @param {Boolean} [escape] Whether or not the word should be escaped.
  #   Defaults to true.
  # @return {Number} width

  calcTextWidth: (text, fontSize, escape) ->
    escape ?= true

    $div = $('<div />').addClass('text-dimension-calc')

    if fontSize?
      $div.css('font-size', fontSize + 'px')

    if escape
      $div.text text
    else
      $div.html text

    $div.appendTo(document.body);
    width = $div.innerWidth()
    $div.remove()

    width


  calcContactsTextOfEmail: (email) ->
    contactsTextTemplate = JST["backbone/templates/primary_pane/email_threads/email_contacts_text"]

    contacts = email.get('contacts')
    collapsedContacts =
      tos: []
      ccs: []
    overflown = false
    contactsText = new Ractive
      template: contactsTextTemplate
      data:
        contacts: collapsedContacts
      adapt: ["Backbone"]

    # Attach to addresses
    i = 0
    while i < contacts.tos.length
      collapsedContacts.tos.push contacts.tos[i]
      contactsTextWidth = @calcTextWidth contactsText.toHTML(), @contactsFontSize, false

      if contactsTextWidth > @contactsTextWrapperWidth
        collapsedContacts.tos.pop()
        overflown = true
        break

      i++

    # Attach cc addresses
    if not overflown
      i = 0
      while i < contacts.ccs.length
        collapsedContacts.ccs.push contacts.ccs[i]
        contactsTextWidth = @calcTextWidth contactsText.toHTML(), @contactsFontSize, false

        if contactsTextWidth > @contactsTextWrapperWidth
          collapsedContacts.ccs.pop()
          overflown = true
          break

        i++

    # Check if " xx more ..." fits the remaining space
    if overflown
      currentTextWidth = @calcTextWidth contactsText.toHTML(), @contactsFontSize, false
      moreLinkWidth = @calcTextWidth " xx more ...", @contactsFontSize

      # If " xx more ..." overflows, remove the last address
      if @contactsTextWrapperWidth - currentTextWidth < moreLinkWidth
        if collapsedContacts.ccs.length > 0
          collapsedContacts.ccs.pop()
        else
          collapsedContacts.tos.pop()

    # Calculate count of hidden addresses, collapsedText and fullText
    moreCount = (contacts.tos.length + contacts.ccs.length) - (collapsedContacts.tos.length + collapsedContacts.ccs.length)
    collapsedText = contactsText.toHTML()
    contactsText.set
      contacts: contacts
    fullText = contactsText.toHTML()

    {
      moreCount: moreCount
      collapsedText: collapsedText
      fullText: fullText
    }


  calcContactsTextOfEmails: () ->
    return if not @currentEmailUID?

    # Get width of current contacts text wrapper
    # If it is hidden or width didn't change, return
    contactsTextWrapperWidth = @$(".tm_email[data-uid='#{@currentEmailUID}'] .tm_email-user-name").innerWidth()
    return if contactsTextWrapperWidth is 0 or contactsTextWrapperWidth is @contactsTextWrapperWidth

    @contactsTextWrapperWidth = contactsTextWrapperWidth

    @emails.forEach (email, index) =>
      email.set
        contactsText: @calcContactsTextOfEmail(email)

  expandContactsText: (evt) ->
    emailUID = $(evt.currentTarget).closest(".tm_email").data("uid")
    email = @emails.get(emailUID)
    email.set
      contactsTextCollapsed: false

    return false


  collapseContactsText: (evt) ->
    evt.preventDefault()

    emailUID = $(evt.currentTarget).closest(".tm_email").data("uid")
    email = @emails.get(emailUID)
    email.set
      contactsTextCollapsed: true

    return false


  setupScroll: ->
    $firstEmail = @$(".tm_email").first()
    $threadSubject = @$ ".tm_mail-thread-subject"

    $threadContext = @$ ".tm_mail-context-threads"
    $threadContext.on "scroll.thread-context", =>
      # Shrink the size of subject line when scrolled
      if $threadContext.scrollTop() == 0
        $threadSubject.removeClass "shrinked"
      else
        $threadSubject.addClass "shrinked"

      # If the user scrolled up to the first email and there are more emails to load, load next page
      if ($firstEmail.position().top is 0) and (@model.get("emails_count") > @emails.length)
        @model.page += 1
        @render()


  renderDrafts: ->
    @embeddedComposeViews = {}

    emails = @model.get("emails")
    for email in emails
      if email.draft_id?
        embeddedComposeView = @embeddedComposeViews[email.uid] = new TuringEmailApp.Views.EmbeddedComposeView(
          app: TuringEmailApp
          emailTemplatesJSON: @emailTemplatesJSON
          uploadAttachmentPostJSON: @uploadAttachmentPostJSON
        )
        embeddedComposeView.emailThread = @model
        embeddedComposeView.render()
        @$(".embedded_compose_view_" + email.uid).append(embeddedComposeView.$el)
        embeddedComposeView.loadEmailDraft(_.last(emails), @model)

  setupSidebar: ->
    $sidebar = @$ ".tm_mail-context-sidebar"
    if $sidebar
      @contextSidebarView =
        new TuringEmailApp.Views.PrimaryPane.EmailThreads.ContextSidebarView
          el: $sidebar
          model: @model
          emailThreadView: @

      @contextSidebarView.render()
      @setupSidebarSwitch()


  setupSidebarSwitch: ->
    $switch = @$ ".sidebar-switch"

    $switch.bootstrapSwitch()
    $switch.bootstrapSwitch("setState", false)
    $switch.bootstrapSwitch("setOnLabel", "Show")
    $switch.bootstrapSwitch("setOffLabel", "Hide")
    $switch.bootstrapSwitch("setTextLabel", "<span><svg><use xlink:href='/images/symbols.svg#profile'></use></svg></span>")
    $switch.on "switch-change", (event, data) =>
      @sidebarCollapsed = !@sidebarCollapsed
      @ractive.set sidebarCollapsed: @sidebarCollapsed


  toggleExpandEmail: (evt) ->
    emailUID = $(evt.currentTarget).closest(".tm_email").data("uid")

    @currentEmailUID = if emailUID == @currentEmailUID then null else emailUID
    @ractive.set currentEmailUID: @currentEmailUID

    # Update contacts text
    # @calcContactsTextOfEmails()

    # trigger expand email event
    emailObj = @emails.get(emailUID).toJSON()
    @trigger("expand:email", this, emailObj)
    @renderRfc2392InlineImages()


  #TODO add tests.
  setupLinks: ->
    @$('.tm_email-body:not(.tm_email-body-compose) a').click (evt) ->
      aTag = $(evt.target).closest("a")
      if aTag.attr('target') != '_blank'
        evt.preventDefault()

        targetUrl = aTag.attr("href")
        window.open(targetUrl, '_blank')


  setupButtons: ->
    if !TuringEmailApp.isSplitPaneMode()
      @$(".email-back-button").click =>
        @trigger("goBackClicked", this)

    @$(".email_reply_button").click =>
      console.log "replyClicked"
      @trigger("replyClicked", this)

    @$(".email_reply_all_button").click =>
      console.log "replyToAllClicked"
      @trigger("replyToAllClicked", this)

    @$(".email_forward_button").click =>
      console.log "forwardClicked"
      @trigger("forwardClicked", this)


  setupQuickReplyButton: ->
    @$(".email-response-btn-group").each ->
      quickReplyView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.QuickReplyView(
        el: $(@)
        emailThreadView: TuringEmailApp.views.mainView.currentEmailThreadView
        app: TuringEmailApp
      )
      quickReplyView.render()


  setupHoverPreviews: ->
    contactsTemplate = JST["backbone/templates/primary_pane/email_threads/email_contacts_tooltip"]

    @$(".email-contacts-tooltip").each (index, element) =>
      contactsPreview = new Ractive
        template: contactsTemplate
        data:
          email: @emails.at(index)
        adapt: ["Backbone"]

      $(element).tooltipster
        contentAsHTML: true
        maxWidth: 300
        positionTracker: true
        content: contactsPreview.toHTML()
        position: 'bottom-left'
        interactive: true
        trigger: 'click'


  setupTooltips: ->
    @$(".email-from").tooltip()
    @$(".email-address-me").tooltip({
      html: true,
      placement : 'bottom',
      container: 'body'
    })
    @$(".email-address-others").tooltip({
      html: true,
      placement : 'bottom',
      container: 'body'
    })


  expandAndMoveToLatestUnreadEmail: ->
    @currentEmailUID = if @emails.length is 1 then @emails.first().get("uid") else @emails.last().get("uid")
    @ractive.set
      currentEmailUID: @currentEmailUID

    if @currentEmailUID
      $currentEmail = @$(".tm_email[data-uid='#{@currentEmailUID}']").first()
      if $currentEmail.length
        $threadContext = @$ ".tm_mail-context-threads"
        $threadContext.scrollTop $currentEmail.position().top


  resolveTwitterEmailRenderingEdgeCase: ->
    @$(".tm_email-body .collapse").removeClass("collapse")


  ###################
  ### Attachments ###
  ###################


  setupAttachmentLinks: ->
    @$(".tm_email-attachment").click (evt) =>
      evt.preventDefault()

      s3Key = $(evt.currentTarget).attr("href")

      TuringEmailApp.Models.EmailAttachment.Download(@app, s3Key)


  renderRfc2392InlineImages: ->
    @$(".tm_email-body img[src*='cid:']").each (index, inlineImage) =>
      emailAttachment = @getEmailAttachmentForInlineImage index, inlineImage

      @updateInlineImageWithAttachment inlineImage, emailAttachment

      @removeAttachmentLink emailAttachment


  getEmailAttachmentForInlineImage: (index, inlineImage) ->
    emailUid = @$(inlineImage).closest(".tm_email").data("uid")
    imageName = inlineImage.src.split("cid:")[1]

    email = $.grep(@model.get("emails"), (email) -> email.uid == emailUid)[0]
    emailAttachments = $.grep(email.email_attachments, (email_attachment) -> email_attachment.filename.split(".")[0] == imageName)
    return if emailAttachments.length > 0 then emailAttachments[0] else email.email_attachments[index]


  updateInlineImageWithAttachment: (inlineImage,emailAttachment) ->
    @$(inlineImage).attr("src", emailAttachment.file_url)


  removeAttachmentLink: (emailAttachment) ->
    @$('a.tm_email-attachment[href="' + emailAttachment.uid + '"]').remove()
