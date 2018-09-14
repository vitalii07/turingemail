class TuringEmailApp.Collections.EmailThreadsCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.EmailThread
  url: "/api/v1/email_threads/in_folder?folder_id=INBOX"

  initialize: (models, options) ->
    super(models, options)

    @app = options.app

    @resetPageTokenIndex()
    @folderIDIs(options?.folderID) if options?.folderID?

  ###############
  ### Network ###
  ###############

  sync: (method, collection, options) ->
    if options?.query?
      $.post("/api/v1/email_accounts/search_threads#{@syncUrlQuery("?")}", query: options.query, next_page_token: @pageTokenIndex).done(
        (data) -> options.success?(data["email_threads"])
      ).fail(
        -> options.error?()
      )
    else
      super(method, collection, options)

  parse: (threadsJSON, options) ->
    TuringEmailApp.Models.EmailThread.SetThreadPropertiesFromJSON(threadJSON) for threadJSON in threadsJSON
    return threadsJSON

  ###############
  ### Setters ###
  ###############

  resetPageTokenIndex: ->
    @pageTokenIndex = 0

  folderIDIs: (folderID) ->
    @resetPageTokenIndex()

    @folderID = folderID
    @setupURL()

    @trigger("change:folderID", this, @folderID)

  pageTokenIndexIs: (pageTokenIndex) ->
    @pageTokenIndex = if @pageTokenIndexIsInRange(pageTokenIndex) then pageTokenIndex else Math.min(@numIndexesInFolder(), pageTokenIndex)

    @trigger("change:pageTokenIndex", this, @pageTokenIndex)

  setupURL: (lastEmailThreadUID, dir) ->
    @url = "/api/v1/email_threads/in_folder?folder_id=" + @folderID if @folderID
    @url += "&last_email_thread_uid=" + lastEmailThreadUID if lastEmailThreadUID
    @url += "&dir=" + dir if dir

  ###############
  ### Getters ###
  ###############

  numIndexesInFolder: ->
    @app.collections.emailFolders.findWhere({label_id: @folderID}).numIndexesInFolder()

  hasNextPage: ->
    return @pageTokenIndex < @numIndexesInFolder()

  hasPreviousPage: ->
    return @pageTokenIndex > 0

  emailThreadsSeenIs: (emailThreadUIDs, seenValue) ->
    postData = {}
    emailUIDs = []

    for emailThreadUID in emailThreadUIDs
      emailThread = @get emailThreadUID

      if emailThread
        for email in emailThread.get("emails")
          email.seen = seenValue
          emailUIDs.push email.uid

    return if emailUIDs.length is 0

    postData.email_uids = emailUIDs
    postData.seen = seenValue

    url = "/api/v1/emails/set_seen#{@syncUrlQuery("?")}"
    $.post url, postData

  pageTokenIndexIsInRange: (pageTokenIndex) ->
    pageTokenIndex > 0 and pageTokenIndex <= @numIndexesInFolder()

