class TuringEmailApp.Views.ComposeView extends TuringEmailApp.Views.RactiveView
  @dateFormat: "m/d/Y g:i a"


  template: JST["backbone/templates/compose/modal_compose"]


  events: -> _.extend {}, super(),
    "click .send-button": "onSubmit"
    "click .send-later-button": "sendEmailDelayed"
    "click .save-button": "saveDraft"
    "click .send-and-archive-button": "sendAndArchive"
    "click .display-cc": "displayCC"
    "click .display-bcc": "displayBCC"
    "click .compose-modal-size-toggle": "sizeToggle"
    "mousedown .ui-icon-gripsmall-diagonal-se": "resizeToggle"
    "click .compose-modal-close-toggle": "closeToggle"
    "click .dropdown-reminder > li > label": "remindToggle"
    "click .reset-datetimepicker": "resetDatetimeClick"
    "change .compose-form .send-later-datetimepicker": "onSendLaterDatetimeChange"

  initialize: (options) ->
    super(options)

    @app = options.app
    @email = new TuringEmailApp.Models.Email()
    @uploadAttachmentPostJSON = options.uploadAttachmentPostJSON
    @is_modal = @.constructor.name == 'ModalComposeView'


  data: -> _.extend {}, super(),
    "static":
      "userAddress": @app.currentEmailAddress()
      "profilePicture": if @app.models.user.get("profile_picture")? then @app.models.user.get("profile_picture") else false
    "dynamic":
      "email": @email
    "computed":
      "email._tos": TuringEmailApp.Mixins.arrayInputConverter
      "email._ccs": TuringEmailApp.Mixins.arrayInputConverter
      "email._bccs": TuringEmailApp.Mixins.arrayInputConverter
      "email._reminder_time":
        "get": "${_}.dateFormat(TuringEmailApp.Views.ComposeView.dateFormat)"
        "set": (val) -> if val is "" or not val? then "" else new Date(val)


  render: ->
    super()

    @postRenderSetup()

    @


  #######################
  ### Setup Functions ###
  #######################

  postRenderSetup: ->
    @setupComposeView()
    @setupDropZone()
    @setupEmailAddressAutocompleteOnAddressFields()
    @setupEmailAddressDeobfuscation()
    @setupEmailTemplatesDropdown()
    @setupAttachmentUpload()
    @setupSendButton()

    @setupDatetimepicker()
    @toggleResetSendLaterDatetimeButton false

    @$(".switch").bootstrapSwitch()

    @setupReminders()

  # Begin setupDatetimepicker #

  setupDatetimepicker: ->
    @$(".datetimepicker").each (i, elm) =>
      options = {
        format: TuringEmailApp.Views.ComposeView.dateFormat
        formatTime: "g:i a"
        theme: if @is_modal then "dark" else ""
        minDate: 0
      }

      $elm = $(elm)
      delete options.parentID
      if $elm.hasClass("reminder-datetimepicker")
        $elm.on "click", (evt) -> evt.stopPropagation()
        options.parentID = @$(".dropdown-reminder")
        options.onSelectDate = (currentTime, input) =>
          @datetimepickerValueSelected()
        options.onSelectTime = (currentTime, input) =>
          @datetimepickerValueSelected()

      $elm.datetimepicker(options)

  datetimepickerValueSelected: ->
    @selectAlwaysRemind() if @neverRemindIsSelected()
    @$(".reminder-datetimepicker").parents(".reminder-collapse").siblings("span").text($(".reminder-datetimepicker").val()+' ')
    @$(".reminder-datetimepicker").parents(".reminder-collapse").siblings("span").addClass("reminder-selected")
    @$(".dropdown-reminder-button span").text($("span.reminder-selected").text()) if $("span.reminder-selected").text() != ''
    @$(".dropdown-reminder-button span").css("color", "#09F") if $("span.reminder-selected").text() != ''

  selectAlwaysRemind: ->
    $($(".dropdown-reminder li .iradio").get(1)).parent("label").click()

  selectNeverRemind: ->
    $($(".dropdown-reminder li .iradio").get(0)).parent("label").click()

  neverRemindIsSelected: ->
    @$(".dropdown-reminder li:first .iradio").hasClass("checked")

  # End setupDatetimepicker #

  setupComposeView: ->
    if isMobile()
      @$(".compose-email-body").redactor
        #focus: true
        minHeight: 200
        toolbar: false
        linebreaks: true
    else
      @$(".compose-email-body").redactor
        #focus: true
        minHeight: 200
        maxHeight: 400
        linebreaks: true
        buttons: ['formatting', 'bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'file', 'link', 'alignment', 'horizontalrule', 'html']
        plugins: ['fontfamily', 'fontcolor', 'fontsize']
        toolbar: !isMobile()
        pasteCallback: (html) ->
          html.split("<br><br><br>").join "<br><br>"

    @composeBody = @$(".redactor-editor")

  setupDropZone: ->
    if @composeBody?
      @$(".tm_compose-body").find("compose-email-dropzone").remove()

      @dropZone = $('<div class="compose-email-dropzone" contenteditable="false"><span>Drop files here</span></div>')
      @dropZone.prependTo(@$(".tm_compose-body"))

      window.dropZoneTimeouts = window.dropZoneTimeouts || {}
      $(document).bind "dragover", (e) =>
        timeout = window.dropZoneTimeouts[@cid]
        if !timeout
          @dropZone.addClass 'in'
        else
          clearTimeout timeout

        window.dropZoneTimeouts[@cid] = setTimeout (=>
          window.dropZoneTimeouts[@cid] = null;
          @dropZone.removeClass 'in'
        ), 100

      $(document).bind 'drop dragover', (e) ->
        e.preventDefault()

  displayCC: (evt) ->
    $(evt.target).hide()
    @$(".cc-input-wrapper").show()
    @$(".tm_compose-body").css("top", $(".tm_compose-header").height() + 30)

  displayBCC: (evt) ->
    $(evt.target).hide()
    @$(".bcc-input-wrapper").show()
    @$(".tm_compose-body").css("top", $(".tm_compose-header").height() + 30)


  onSubmit: (evt) ->
    console.log "SEND clicked! Sending..."
    @sendEmail()

  sendAndArchive: ->
    console.log "send-and-archive clicked"
    @sendEmail()
    @trigger("archiveClicked", this)

  setupEmailAddressAutocompleteOnAddressFields: ->
    @setupEmailAddressAutocomplete ".compose-form .to-input"
    @setupEmailAddressAutocomplete ".compose-form .cc-input"
    @setupEmailAddressAutocomplete ".compose-form .bcc-input"

  # TODO write more thorough tests
  setupEmailAddressAutocomplete: (selector) ->
    @$el.find(selector).autocomplete(
      source: (request, response) ->
        $.ajax
          data: {'email_account_id' : window.currentEmailAccountId}
          url: "/api/v1/people/search/" + request.term.split(",").pop()
          success: (data) ->
            contacts = []
            namesAndAddresses = []
            for remoteContact in data
              contact = {}
              contact["value"] = remoteContact["email_address"]
              contact["label"] = if remoteContact["name"]? then remoteContact["name"] else " "
              contact["desc"] = remoteContact["email_address"]
              contacts.push contact
            response contacts
      focus: (evt, ui) ->
        false
      select: (evt, ui) ->
        if $(selector).val().indexOf(",") > -1
          values = $(selector).val().split(",")
          values.pop()
          $(selector).val( values.join(",") + ", " + ui.item.value)
        else
          $(selector).val ui.item.value
        false
    ).autocomplete("instance")._renderItem = (ul, item) ->
      if item.label is " "
        $("<li>").append("<span>" + item.desc + "</span><small>" + item.desc + "</small>").appendTo ul
      else
        $("<li>").append("<span>" + item.label + "</span><small>" + item.desc + "</small>").appendTo ul

    @$el.find(selector).attr "autocomplete", "on"

  setupEmailAddressDeobfuscation: ->
    @$(".compose-form .to-input, .compose-form .cc-input, .compose-form .bcc-input").keyup ->
      inputText = $(@).val()
      indexOfObfuscatedEmail = inputText.search(/(.+) ?\[at\] ?(.+) ?[dot] ?(.+)/)

      if indexOfObfuscatedEmail != -1
        $(@).val(inputText.replace(" [at] ", "@").replace(" [dot] ", "."))

  # setupLinkPreviews: ->
  #   @$(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").bind "keydown", "space return shift+return", =>
  #     emailHtml = @$(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable").html()
  #     indexOfUrl = emailHtml.search(/((([A-Za-z]{3,9}:(?:\/\/)?)(?:[-;w]+@)?[A-Za-z0-9.-]+|(?www.|[-;w]+@)[A-Za-z0-9.-]+)((?w-_]*)?\??(?w_]*)#?(?w]*))?)/)

  #     linkPreviewIndex = emailHtml.search("compose-link-preview")

  #     if indexOfUrl isnt -1 and linkPreviewIndex is -1
  #       link = emailHtml.substring(indexOfUrl)?.split(" ")?[0]

  #       websitePreview = new TuringEmailApp.Models.WebsitePreview(
  #         websiteURL: link
  #       )

  #       @websitePreviewView = new TuringEmailApp.Views.WebsitePreviewView(
  #         model: websitePreview
  #         el: @$(".compose-form iframe.cke_wysiwyg_frame.cke_reset").contents().find("body.cke_editable")
  #       )
  #       websitePreview.fetch()

  setupEmailTemplatesDropdown: ->
    @emailTemplatesDropdownView = new TuringEmailApp.Views.EmailTemplatesDropdownView(
      collection: @app.collections.emailTemplates
      el: $("<li>").insertAfter(@$(".redactor-toolbar").children().last())
      composeView: @
    )
    @emailTemplatesDropdownView.render()

  setupSendButton: ->
    sendLinkWrap = @$("a.send-button").parent()
    sendLinkWrap.hide()

  # TODO write tests
  setupAttachmentUpload: ->
    @attachmentS3Keys = {}

    @$(".tm_upload-attachments").empty()
    @addEmptyAttachment()

  # TODO write tests
  addEmptyAttachment: ->
    uploadAttachments = @$(".tm_upload-attachments")
    fileContainer = $('<li class="tm_upload-attachment tm_upload-nofile">').prependTo(uploadAttachments)
    fileInput = $('<input type="file">').appendTo(fileContainer).hide()
    progressBar = $('<span class="tm_progress-bar">')
    fileName = $('<small class="tm_upload-filename">').text "Attach a file..."
    fileSize = $('<small class="tm_upload-filesize">')
    fileInput.after $('<span class="tm_progress">').append(progressBar)
    fileInput.after fileSize
    fileInput.after fileName

    fileInput.show()

    submitButton = @$(".send-button")

    fileInput.fileupload
      fileInput: fileInput
      dropZone: @dropZone
      url: @uploadAttachmentPostJSON.url
      type: "POST"
      autoUpload: true
      formData: @uploadAttachmentPostJSON.fields
      paramName: "file"
      dataType: "XML"
      replaceFileInput: false

      progressall: (evt, data) ->
        progress = parseInt(data.loaded / data.total * 100, 10)
        progressBar.css "width", progress + "%"

      send: (e, data) ->
        fileContainer.removeClass "tm_upload-nofile"
        fileName.text data.files[0].name
        submitButton.prop "disabled", true
        fileInput.hide()

      done: (evt, data) =>
        fileContainer.addClass "tm_upload-complete"
        submitButton.prop "disabled", false
        fileSize.text TuringEmailApp.Mixins.bytesToHumanReadableFileSize(data.total)

        uuid = Date.now()

        fileContainer.click =>
          delete @attachmentS3Keys[uuid]
          fileContainer.remove()

        key = $(data.jqXHR.responseXML).find("Key").text()
        @attachmentS3Keys[uuid] = key

        @addEmptyAttachment()

      fail: (evt, data) ->
        submitButton.prop "disabled", false
        fileSize.text "Upload failed"
        fileInput.show()

  addAttachment: (emailAttachment) ->
    uploadAttachments = @$(".tm_upload-attachments")
    fileContainer = uploadAttachments.find ".tm_upload-attachment.tm_upload-nofile"
    fileName = fileContainer.find ".tm_upload-filename"
    fileSize = fileContainer.find ".tm_upload-filesize"

    fileContainer.removeClass("tm_upload-nofile").addClass("tm_upload-complete")
    fileName.text emailAttachment.get("filename")
    fileSize.text TuringEmailApp.Mixins.bytesToHumanReadableFileSize(emailAttachment.get("file_size"))

    uuid = Date.now()

    fileContainer.click =>
      delete @attachmentS3Keys[uuid]
      fileContainer.remove()

      return false

    s3Key = emailAttachment.get("uid")
    @attachmentS3Keys[uuid] = s3Key

    @addEmptyAttachment()

  sizeToggle: (evt) ->
    @$(".compose-modal-dialog-small").animate {
      height: "10000",
      width: "10000"
    }, 900, =>
      @$(".compose-modal-dialog").toggleClass("compose-modal-dialog-large compose-modal-dialog-small")
      @$(evt.currentTarget).toggleClass("tm_modal-button-compress tm_modal-button-expand")

    @$(".compose-modal-dialog-large").animate {
      height: "562px",
      width: "900px"
    }, 300, =>
      @$(".compose-modal-dialog").toggleClass("compose-modal-dialog-large compose-modal-dialog-small")
      @$(evt.currentTarget).toggleClass("tm_modal-button-compress tm_modal-button-expand")

  resizeToggle: (evt) ->
    @$(".compose-modal-dialog").removeClass("compose-modal-dialog-large").addClass("compose-modal-dialog-small")
    @$(".compose-modal-size-toggle").removeClass("tm_modal-button-compress").addClass("tm_modal-button-expand")

  closeToggle: (evt) ->
    @$('.compose-modal').removeClass 'modal-left modal-right modal-bottom modal-top'

  remindToggle: (evt) ->
    evt.stopPropagation()
    @$(".dropdown-reminder > li > label").removeClass("open-reminder")
    @$(evt.currentTarget).addClass("open-reminder")
    @$(".reminder-collapse").slideUp("fast")
    @$(evt.currentTarget).children(".reminder-collapse").slideToggle("fast")

  setupReminders: ->
    @$(".iradio ins").off("click")

    @$(".i-checks").iCheck
      radioClass: "iradio" + (if @is_modal then " iradio-dark" else "")

    @$(".iradio").parent("label").click (ele) =>
      @$(ele.target).parents(".reminder-collapse").siblings("span").text($(ele.target).text()+' ')
      @$(ele.target).parents(".reminder-collapse").siblings("span").addClass("reminder-selected")
      @$(".dropdown-reminder-button span").text($("span.reminder-selected").text()) if $("span.reminder-selected").text() != ''
      @$(".dropdown-reminder-button span").css("color", "#09F") if $("span.reminder-selected").text() != ''
      @$(".reminder-datetimepicker").val("") if @$(".reminder-datetimepicker").val() != "" and $(ele.target).text().trim() is "Never"

    @$(".reminder-time-section .iradio").parent("label").click (ele) =>
      if $("span.reminder-selected").text() != ''
        timeToSet = $(ele.target).parent().find(".i-checks").val()
        @$(".reminder-datetimepicker").val(timeToSet)
        @email.set("reminder_time", new Date(timeToSet))

  #########################
  ### Display Functions ###
  #########################

  show: ->
    @$(".compose-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()
    @$(".compose-modal-dialog").resizable()
    window.setTimeout(=>
      if @$(".to-input").val() is ""
        @$(".to-input").focus()
      else
        @$(".redactor-editor").focus()
      @$('.tm_compose-footer > .dropdown .dropdown-menu').css "left", @$('.tm_compose-footer > .dropdown label').width() + 9
    , 1000)
    @updateSendButtonText @sendLaterDatetime()

    for addressField in ["cc", "bcc"]
      @$(".display-" + addressField).click() if @email.get(addressField + "s")?

  hide: ->
    @$(".compose-modal").modal "hide"

  bodyHtml: ->
    return @composeBody.html()

  bodyHtmlIs: (bodyHtml) ->
    @email.set("html_part", bodyHtml)
    @composeBody.html(bodyHtml)

  prependBodyHTML: (bodyHtml) ->
    @email.set("html_part", bodyHtml + @bodyHtml())
    @composeBody.prepend(bodyHtml)

  bodyText: ->
    return @composeBody.text()

  bodyTextIs: (bodyText) ->
    @composeBody.text(bodyText)

  sendLaterDatetime: ->
    @$(".compose-form .send-later-datetimepicker").val()

  sendLaterDatetimeIs: (datetime) ->
    @$(".compose-form .send-later-datetimepicker").val(datetime)
    @updateSendButtonText datetime

  resetView: ->
    console.log("ComposeView RESET!!")

    @removeEmailSentAlert()

    @currentEmailDraft = null
    @emailInReplyToUID = null
    @emailThreadParent = null
    @currentEmailDelayed = null

    @email.clear()

    @sendLaterDatetimeIs("")
    @selectNeverRemind()

    @bodyHtmlIs("")
    @$(".compose-form .send-later-switch").bootstrapSwitch("setState", false, true)
    @$(".compose-form .tracking-switch").bootstrapSwitch("setState", false, true)

    @$(".compose-modal .display-cc").show()
    @$(".compose-modal .cc-input-wrapper").hide()
    @$(".compose-modal .display-bcc").show()
    @$(".compose-modal .bcc-input-wrapper").hide()
    @$(".compose-modal .tm_compose-body").css("top", "100px")

    @setupAttachmentUpload()

  showEmailSentAlert: (emailSentJSON) ->
    console.log "ComposeView showEmailSentAlert"

    @removeEmailSentAlert() if @currentAlertToken?

    @currentAlertToken = @app.showAlert('Your message has been sent. <span class="tm_alert-link undo-email-send">Undo</span>', "alert-success")
    $(".undo-email-send").click =>
      clearTimeout(TuringEmailApp.sendEmailTimeout)

      @removeEmailSentAlert()
      @loadEmail(emailSentJSON)
      @show()

      @$('.compose-modal').removeClass 'modal-left modal-bottom modal-top'
      @$('.compose-modal').addClass 'modal-right'

  removeEmailSentAlert: ->
    console.log "ComposeView REMOVE emailSentAlert"

    if @currentAlertToken?
      @app.removeAlert(@currentAlertToken)
      @currentAlertToken = null

  updateSendButtonText: (sendLaterDatetime) ->
    sendButton = @$(".compose-form button.main-send-button")
    sendButtonText = @$(".compose-form .send-button-text")
    sendLinkWrap = @$("a.send-button").parent()

    if sendLaterDatetime
      sendButtonText.text("Send Later")
      @$('.compose-modal .main-send-button .icon').html('<use xlink:href="/images/symbols.svg#compose-later"></use>')
      sendButton.addClass("send-later-button")
      sendButton.removeClass("send-button")
      sendLinkWrap.show()
    else
      sendButtonText.text("Send")
      @$('.compose-modal .main-send-button .icon').html('<use xlink:href="/images/symbols.svg#compose-send"></use>')
      sendButton.addClass("send-button")
      sendButton.removeClass("send-later-button")
      sendLinkWrap.hide()

  toggleResetSendLaterDatetimeButton: (visible) ->
    if visible
      @$(".reset-datetimepicker").show()
    else
      @$(".reset-datetimepicker").hide()

  resetDatetimeClick: (evt)->
    @$(".send-later-datetimepicker").val ""
    @updateSendButtonText ""
    @toggleResetSendLaterDatetimeButton false

  onSendLaterDatetimeChange: (evt) ->
    sendLaterDatetime = $(evt.target).val()

    @updateSendButtonText sendLaterDatetime
    @toggleResetSendLaterDatetimeButton sendLaterDatetime != ""

  ############################
  ### Load Email Functions ###
  ############################

  loadEmpty: ->
    @resetView()

  loadEmailSignature: ->
    if @app.models.userConfiguration.get("email_signature_uid")?
      @currentEmailSignature = new TuringEmailApp.Models.EmailSignature(
        uid: @app.models.userConfiguration.get("email_signature_uid")
      )
      @currentEmailSignature.fetch(
        success: (model, response, options) =>
          preSignatureHTMLPadding = "<br /><br />"
          signatureHTML = preSignatureHTMLPadding + model.get("html")
          @prependBodyHTML signatureHTML
      )

  loadEmail: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmail!!")
    @resetView()

    @loadEmailHeaders(emailJSON)
    @loadEmailBody(emailJSON)

    @emailThreadParent = emailThreadParent

  loadEmailDraft: (emailDraftJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailDraft!!")
    @resetView()

    @loadEmailHeaders(emailDraftJSON)
    @loadEmailBody(emailDraftJSON)

    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft(emailDraftJSON)
    @emailThreadParent = emailThreadParent

  loadEmailDelayed: (emailDelayed) ->
    console.log "ComposeView loadEmailDelayed!!"
    @resetView()

    emailDelayedJSON = emailDelayed.toJSON()
    @loadEmailHeaders(emailDelayedJSON)
    @loadEmailBody(emailDelayedJSON)
    @loadEmailFooters(emailDelayedJSON)

    @currentEmailDelayed = emailDelayed

  loadEmailAsReply: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsReply!!")
    @resetView()

    @ractive.set
      "email._tos": (emailJSON.reply_to_address || emailJSON.from_address)
      "email.subject": @subjectWithPrefixFromEmail(emailJSON, "Re: ")

    @loadEmailBody(emailJSON, true)

    @emailInReplyToUID = emailJSON.uid
    @emailThreadParent = emailThreadParent

  loadEmailAsReplyToAll: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsReplyToAll!!")
    @resetView()

    console.log emailJSON

    @ractive.set
      "email._tos": emailJSON["tos"] + ", " + emailJSON.from_address
      "email._ccs": emailJSON["ccs"]
      "email.subject": @subjectWithPrefixFromEmail(emailJSON, "Re: ")
    @loadEmailBody(emailJSON, true)

    @emailInReplyToUID = emailJSON.uid
    @emailThreadParent = emailThreadParent

    @removeUserEmailAddressFromAddressFields()

  loadEmailAsForward: (emailJSON, emailThreadParent) ->
    console.log("ComposeView loadEmailAsForward!!")
    @resetView()

    @ractive.set
      "email.subject": @subjectWithPrefixFromEmail(emailJSON, "Fwd: ")
    @loadEmailBody(emailJSON, true)

    @emailThreadParent = emailThreadParent

  loadEmailHeaders: (emailJSON) ->
    console.log("ComposeView loadEmailHeaders!!")
    @ractive.set
      "email._tos": emailJSON["tos"]
      "email._ccs": emailJSON["ccs"]
      "email._bccs": emailJSON["bccs"]
      "email.subject": @subjectWithPrefixFromEmail(emailJSON)

  loadEmailBody: (emailJSON, isReply=false) ->
    console.log("ComposeView loadEmailBody!!")

    if isReply
      body = @formatEmailReplyBody(emailJSON)
    else
      [body, html] = @parseEmail(emailJSON)
      body = $.parseHTML(body) if not html && body != ""

    @bodyHtmlIs(body)

    return body

  loadEmailFooters: (emailJSON) ->
    console.log("ComposeView loadEmailFooters!!")

    if emailJSON.send_at?
      @sendLaterDatetimeIs(moment(emailJSON.send_at).format("MM/DD/YYYY h:mm a"))

  parseEmail: (emailJSON) ->
    htmlFailed = true

    if emailJSON.html_part? and emailJSON.html_part != ""
      try
        emailHTML = $($.parseHTML(emailJSON.html_part))

        if emailHTML.length is 0 || not emailHTML[0].nodeName.match(/body/i)?
          body = $("<span />")
          body.html(emailHTML)
        else
          body = emailHTML

        htmlFailed = false
      catch error
        console.log error
        htmlFailed = true

    if htmlFailed
      bodyText = ""

      if emailJSON.text_part? and emailJSON.text_part != ""
        text = emailJSON.text_part

        for line in text.split("\n")
          bodyText += "> " + line + "\n"

      else if emailJSON.body_text? and emailJSON.body_text != ""
        bodyText = emailJSON.body_text

      body = bodyText

    return [body, !htmlFailed]

  ##############################
  ### Format Email Functions ###
  ##############################

  formatEmailReplyBody: (emailJSON) ->
    tDate = new TDate()
    tDate.initializeWithISO8601(emailJSON.date)

    headerText = "\r\n\r\n"
    headerText += tDate.longFormDateString() + ", " + emailJSON.from_address + " wrote:"
    headerText += "\r\n\r\n"

    headerText = headerText.replace(/\r\n/g, "<br />")

    [body, html] = @parseEmail(emailJSON)

    if html
      $(body).prepend(headerText)
    else
      body = body.replace(/\r\n/g, "<br />")
      body = $($.parseHTML(headerText + body))

    return body

  subjectWithPrefixFromEmail: (emailJSON, subjectPrefix="") ->
    console.log("ComposeView subjectWithPrefixFromEmail")
    return subjectPrefix if not emailJSON.subject

    subjectWithoutForwardAndReplyPrefixes = emailJSON.subject.replace(/(re|fwd):\s/ig, "")
    return subjectPrefix + subjectWithoutForwardAndReplyPrefixes

  removeUserEmailAddressFromAddressFields: ->
    if @email.get("tos")?
      @ractive.set
        "email._tos": @email.get("tos").filter (address) => address isnt @app.currentEmailAddress()

    if @email.get("ccs")?
      @ractive.set
        "email._ccs": @email.get("ccs").filter (address) => address isnt @app.currentEmailAddress()

  ###################
  ### Email State ###
  ###################

  updateDraft: ->
    console.log "ComposeView updateDraft!"
    @currentEmailDraft = new TuringEmailApp.Models.EmailDraft() if not @currentEmailDraft?
    @updateEmail(@currentEmailDraft)

  updateEmail: (email) ->
    console.log "ComposeView updateEmail!"

    @ractive.updateModel()

    email.set(@email.toJSON())

    email.set
      "email_in_reply_to_uid": @emailInReplyToUID
      "attachment_s3_keys": _.values(@attachmentS3Keys)
      "reminder_enabled": (email.get("reminder_type") != "never")
      "text_part": @bodyText()

    email.set
      "html_part": '<span style="font-family: Helvetica;">' + email.get("html_part") + '</span>'

  emailHasRecipients: (email) ->
    return email.get("tos").length > 1 || (email.get("tos")[0]? and email.get("tos")[0].trim() != "") ||
           email.get("ccs").length > 1 || (email.get("ccs")[0]? and email.get("ccs")[0].trim() != "") ||
           email.get("bccs").length > 1 || (email.get("bccs")[0]? and email.get("bccs")[0].trim() != "")

  checkReminder: (email) ->
    return true if !email.get("reminder_enabled")
    return @checkDate(email.get("reminder_time"), "reminder time")

  checkDate: (dateString, description) ->
    dateTime = new Date(dateString)

    if dateTime.toString() == "Invalid Date"
      @app.showAlert("The " + description + " is invalid.", "alert-error", 5000)
      return false
    else if dateTime < new Date()
      @app.showAlert("The " + description + " is before the current time.", "alert-error", 5000)
      return false

    return true

  ###################
  ### Email Draft ###
  ###################

  saveDraft: (force = false) ->
    console.log "SAVE clicked - saving the draft!"
    @app.showAlert("Email draft saving.", "alert-success", 5000)

    # if already in the middle of saving, no reason to save again
    # it could be an error to save again if the draft_id isn't set because it would create duplicate drafts
    if @savingDraft
      console.log "SKIPPING SAVE - already saving!!"
      return

    @updateDraft()

    if !force &&
       !@emailHasRecipients(@currentEmailDraft) &&
       @currentEmailDraft.get("subject").trim() == "" &&
       @currentEmailDraft.get("html_part")?.trim() == "" && @currentEmailDraft?.get("text_part").trim() == "" &&
       not @currentEmailDraft.get("draft_id")?

      console.log "SKIPPING SAVE - BLANK draft!!"
    else
      @savingDraft = true

      @currentEmailDraft.save(null,
        success: (model, response, options) =>
          console.log "SAVED! setting draft_id to " + response.draft_id

          model.set("draft_id", response.draft_id)
          @trigger "change:draft", this, model, @emailThreadParent

          @savingDraft = false

          @app.showAlert("Email draft saved.", "alert-success", 5000)

        error: (model, response, options) =>
          console.log "SAVE FAILED!!!"
          @savingDraft = false
      )

  ##################
  ### Send Email ###
  ##################

  sendEmailWithCallback: (callback, callbackWithDraft, draftToSend=null) ->
    if @currentEmailDraft? || draftToSend?
      console.log "sending DRAFT"

      if not draftToSend?
        console.log "NO draftToSend - not callback so update the draft and save it"
        # need to update and save the draft state because reset below clears it
        @updateDraft()
        draftToSend = @currentEmailDraft

        if !@emailHasRecipients(draftToSend)
          @app.showAlert("Email has no recipients!", "alert-error", 5000)
          return

        if !@checkReminder(draftToSend)
          return

        @resetView()
        @hide()

      if @savingDraft
        console.log "SAVING DRAFT!!!!!!! do TIMEOUT callback!"
        # if still saving the draft from save-button click need to retry because otherwise multiple drafts
        # might be created or the wrong version of the draft might be sent.
        setTimeout (=>
          @sendEmailWithCallback(callback, callbackWithDraft, draftToSend)
        ), 500
      else
        console.log "NOT in middle of draft save - saving it then sending"
        callbackWithDraft(draftToSend)
    else
      # easy case - no draft just send the email!
      console.log "NO draft! Sending"
      emailToSend = new TuringEmailApp.Models.Email()
      @updateEmail(emailToSend)

      if !@emailHasRecipients(emailToSend)
        @app.showAlert("Email has no recipients!", "alert-error", 5000)
        return

      if !@checkReminder(emailToSend)
        return

      if emailToSend.get("subject") == ""
        @app.showAlert("Email subject is not set!", "alert-error", 5000)
        return

      @resetView()
      @hide()

      callback(emailToSend)

  sendEmail: ->
    @$('.compose-modal').removeClass 'modal-bottom modal-left modal-top'
    @$('.compose-modal').addClass 'modal-right'

    console.log "ComposeView sendEmail!"
    console.log @attachmentS3Keys

    currentEmailDelayed = @currentEmailDelayed

    @sendEmailWithCallback(
      (emailToSend) =>
        @sendUndoableEmail(emailToSend, currentEmailDelayed)

      (draftToSend) =>
        draftToSend.save(null, {
          success: (model, response, options) =>
            console.log "SAVED! setting draft_id to " + response.draft_id
            draftToSend.set("draft_id", response.draft_id)
            @trigger "change:draft", this, model, @emailThreadParent

            @sendUndoableEmail(draftToSend, currentEmailDelayed)
        })
    )

  sendEmailDelayed: (sendLaterDatetimeVal=null) ->
    @$('.compose-modal').removeClass 'modal-left modal-right modal-top'
    @$('.compose-modal').addClass 'modal-bottom'

    console.log "sendEmailDelayed!!!"

    dateTimePickerVal = if sendLaterDatetimeVal? then sendLaterDatetimeVal else @$(".compose-form .send-later-datetimepicker").val()
    if !@checkDate(dateTimePickerVal, "send later time")
      return

    sendAtDatetime = new Date(dateTimePickerVal)
    currentEmailDelayed = @currentEmailDelayed

    @sendEmailWithCallback(
      (emailToSend) =>
        deferred = $.Deferred()

        if currentEmailDelayed?
          currentEmailDelayed.destroy().then ->
            deferred.resolve()
        else
          deferred.resolve()

        deferred.done =>
          emailToSend.sendLater(sendAtDatetime).done (data) =>
            scheduleEmail = new TuringEmailApp.Models.DelayedEmail(data)
            @trigger "addScheduleEmail", scheduleEmail
            @app.showAlert("Email scheduled to be sent.", "alert-success", 5000)

      (draftToSend) =>
        draftToSend.sendLater(sendAtDatetime).done(
          => @trigger "change:draft", this, model, @emailThreadParent
        )
    )

  sendUndoableEmail: (emailToSend, currentEmailDelayed) ->
    console.log "ComposeView sendUndoableEmail! - Setting up Undo button"
    @showEmailSentAlert(emailToSend.toJSON())

    TuringEmailApp.sendEmailTimeout = setTimeout (=>
      console.log "ComposeView sendUndoableEmail CALLBACK! doing send"
      @removeEmailSentAlert()

      deferred = $.Deferred()
      if currentEmailDelayed?
        currentEmailDelayed.destroy().then ->
          deferred.resolve()
      else
        deferred.resolve()

      deferred.done =>
        if emailToSend instanceof TuringEmailApp.Models.EmailDraft
          console.log "sendDraft!"
          emailToSend.sendDraft(
            @app
            =>
              @trigger "change:draft", this, emailToSend, @emailThreadParent
            =>
              @sendUndoableEmailError(emailToSend.toJSON())
          )
        else
          console.log "send email!"
          emailToSend.sendEmail().done(=>
            @trigger "change:draft", this, emailToSend, @emailThreadParent
          ).fail(=>
            @sendUndoableEmailError(emailToSend.toJSON())
          )
    ), 5000

  sendUndoableEmailError: (emailToSendJSON) ->
    console.log "sendUndoableEmailError!!!"

    @loadEmail(emailToSendJSON, @emailThreadParent)
    @show()

    @app.showAlert("There was an error in sending your email", "alert-error", 5000)
