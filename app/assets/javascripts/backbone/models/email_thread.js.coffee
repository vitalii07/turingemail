class TuringEmailApp.Models.EmailThread extends TuringEmailApp.Models.EmailGroup
  idAttribute: "uid"


  @SetThreadPropertiesFromJSON: (threadJSON) ->
    res = @prototype.parse.call null, threadJSON


  @setThreadParsedProperties: (threadParsed, messages, messageInfo) ->
    threadParsed.snippet = if messageInfo.snippet? then messageInfo.snippet else ""

    emailParsed = {}
    TuringEmailApp.Models.Email.parseHeaders(emailParsed, messageInfo.payload.headers)

    _.extend(threadParsed, _.pick(emailParsed, ["from_name", "from_address", "date", "subject"]))

    folderIDs = []

    threadParsed.seen = true
    for message in messages
      if message.labelIds?
        folderIDs = folderIDs.concat(message.labelIds)
        threadParsed.seen = false if message.labelIds.indexOf("UNREAD") != -1

    threadParsed.folder_ids = _.uniq(folderIDs)

    return threadParsed


  @removeFromFolder: (app, emailThreadUIDs, emailFolderID, success, error) ->
    postData =
      email_thread_uids: emailThreadUIDs
      email_folder_id: emailFolderID

    $.post("/api/v1/email_threads/remove_from_folder#{TuringEmailApp.Mixins.syncUrlQuery("?")}", postData).done(-> success?()).fail(-> error?())


  @trash: (app, emailThreadUIDs) ->
    postData = email_thread_uids: emailThreadUIDs
    $.post("/api/v1/email_threads/trash#{TuringEmailApp.Mixins.syncUrlQuery("?")}", postData)


  @snooze: (app, emailThreadUIDs, minutes) ->
    postData =
      email_thread_uids: emailThreadUIDs
      minutes: minutes

    $.post("/api/v1/email_threads/snooze#{TuringEmailApp.Mixins.syncUrlQuery("?")}", postData)


  @deleteDraftRequest: (draftID) ->
    return


  @deleteDraft: (app, draftIDs) ->
    return


  @applyGmailLabel: (app, emailThreadUIDs, labelID, labelName, success, error) ->
    postData = email_thread_uids: emailThreadUIDs
    postData.gmail_label_id = labelID if labelID?
    postData.gmail_label_name = labelName if labelName?

    return $.post("/api/v1/email_threads/apply_gmail_label#{TuringEmailApp.Mixins.syncUrlQuery("?")}", postData).done(
      (data) -> success?(data)).fail(
      (data) -> error?(data)
    )


  @moveToFolder: (app, emailThreadUIDs, folderID, folderName, currentFolderIDs, success, error) ->
    postData = email_thread_uids: emailThreadUIDs
    postData.email_folder_id = folderID if folderID?
    postData.email_folder_name = folderName if folderName?

    return $.post("/api/v1/email_threads/move_to_folder#{TuringEmailApp.Mixins.syncUrlQuery("?")}", postData).done(
      (data) -> success?(data)
    ).fail(
      (data) -> error?(data)
    )


  validation:
    uid:
      required: true

    emails:
      required: true
      isArray: true

  initialize: (attributes, options) ->
    super(attributes, options)

    if attributes?.uid?
      @emailThreadUID = attributes.uid

    if options?.emailThreadUID?
      @emailThreadUID = options.emailThreadUID

    @listenTo(@, "seenChanged", @seenChanged)


  ###############
  ### Network ###
  ###############

  url: ->
    "/api/v1/email_threads/show/#{@emailThreadUID}?page=#{@page}"


  load: (options, force=false) ->
    if @get("loaded") and not force
      options.success?()
    else
      if @loading
        setTimeout(
          => @load(options, force)
          250
        )

        return

      @loading = true
      @emailThreadUID = @get("uid")

      options ?= {}
      success = options.success
      options.success = (model, response) =>
        draftInfo = @get("draftInfo")
        if draftInfo
          message = _.find(@get("emails"), (emailJSON) -> emailJSON.uid == draftInfo.message.id)
          message.draft_id = draftInfo.id if message?

        @loading = false
        success?()

      error = options.error
      options.error = =>
        @loading = false
        error?()

      @fetch(options)


  ##############
  ### Events ###
  ##############


  seenChanged: (model, seenValue) ->
    postData = {}
    emailUIDs = []

    for email in @get("emails")
      email.seen = seenValue
      emailUIDs.push email.uid

    return if emailUIDs.length is 0

    postData.email_uids = emailUIDs
    postData.seen = seenValue

    url = "/api/v1/emails/set_seen#{@syncUrlQuery("?")}"
    $.post url, postData


  ###############
  ### Actions ###
  ###############


  removeFromFolder: (emailFolderID) ->
    TuringEmailApp.Models.EmailThread.removeFromFolder(@app, [@get("uid")], emailFolderID, undefined, undefined)


  trash: ->
    TuringEmailApp.Models.EmailThread.trash(@app, [@get("uid")])


  snooze: (minutes) ->
    TuringEmailApp.Models.EmailThread.snooze(@app, [@get("uid")], minutes)


  deleteDraft: ->
    TuringEmailApp.Models.EmailThread.deleteDraft(@app, [@get("draft_id")])


  applyGmailLabel: (labelID, labelName) ->
    TuringEmailApp.Models.EmailThread.applyGmailLabel(@app, [@get("uid")], labelID, labelName,
      (data) => @trigger("change:folder", this, data)
      undefined
    )


  moveToFolder: (folderID, folderName) ->
    TuringEmailApp.Models.EmailThread.moveToFolder(@app, [@get("uid")], folderID, folderName, @get("folder_ids"),
      (data) => @trigger("change:folder", this, data)
      undefined
    )

  setSeen: (seenValue, options) ->
    if @get("seen") != seenValue
      @set("seen", seenValue)
      @trigger("seenChanged", @, seenValue) unless options?.silent?
