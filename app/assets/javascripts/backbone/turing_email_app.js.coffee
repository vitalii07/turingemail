#= require_self
#= require_tree ./mixins
#= require ./core/base_model
#= require_tree ./core
#= require_tree ./templates
#= require_tree ./validations
#= require ./models/email
#= require ./models/email_group
#= require ./models/installed_apps/installed_app
#= require_tree ./models
#= require_tree ./collections
#= require ./views/collection_view
#= require ./views/primary_pane/email_threads/list_item_view
#= require ./views/primary_pane/email_threads/list_view
#= require ./views/primary_pane/analytics/reports/report_view
#= require ./views/compose/compose_view
#= require ./views/toolbar/toolbar_view
#= require_tree ./views
#= require_tree ./routers

window.backboneWrapError = (model, options) ->
  error = options.error
  options.error = (resp) ->
    error model, resp, options  if error
    model.trigger "error", model, resp, options
    return

  return

window.TuringEmailApp = new(Backbone.View.extend(
  Models: {}
  Views: {}
  Collections: {}
  Routers: {}
  Mixins: {}

  setupListeners: (source) ->
    @listenTo(source, arg, @[arg]) for arg in _.rest(arguments)

  start: (userJSON, userConfigurationJSON, emailTemplateCategoriesJSON, emailTemplatesJSON, uploadAttachmentPostJSON, emailFoldersJSON, emailTrackersJSON, emailAccountsJSON) ->
    @models = {}
    @views = {}
    @collections = {}
    @routers = {}

    @cleanUrl()

    @setupUser(userJSON, userConfigurationJSON)

    @setupKeyboardHandler()

    # email accounts
    @setupAndLoadEmailAccounts emailAccountsJSON

    # email template categories
    @setupEmailTemplateCategories()
    @loadEmailTemplateCategories emailTemplateCategoriesJSON

    # email templates
    @setupEmailTemplates()
    @loadEmailTemplates emailTemplatesJSON

    @setupMainView emailTemplatesJSON, uploadAttachmentPostJSON

    @setupToolbar()

    @setupComposeView()
    @setupCreateFolderView()
    @setupEmailThreads()
    @setupRouters()

    # email folders
    @setupEmailFolders()
    @loadEmailFolders emailFoldersJSON

    # email trackers
    @setupEmailTrackers()
    @loadEmailTrackers emailTrackersJSON

    Backbone.history.start() if not Backbone.History.started

    windowLocationHash = window.location.hash.toString()
    if windowLocationHash is ""
      if @models.userConfiguration.inboxTabsIsEnabled()
        @routers.emailFoldersRouter.navigate("#email_folder/IMPORTANT", trigger: true)
      else
        @routers.emailFoldersRouter.navigate("#email_folder/INBOX", trigger: true)

    @setupSyncTimeout()
    @setupObserver()


  #######################
  ### Setup Functions ###
  #######################

  cleanUrl: ->
    history?.replaceState({}, 'Mail', '/mail') if window.location.search.indexOf("email_account_id=") > -1

  resetSearchQuery: ->
    @views.toolbarView.resetSearchQuery()

  setupObserver: ->
    observe = =>
      excluded = []
      for view in @_observedViews
        present = document.body.contains(view.$el[0])
        if (view._rendered && !present)
          view.remove()
          view._rendered = false
          excluded.push view
        else if (!view._rendered && present)
          view._rendered = true
      @_observedViews = _.difference @_observedViews, excluded

    # Assigning to member variable just to make sure it won't be removed by
    # the garbage collector
    if MutationObserver?
      @observer = new MutationObserver observe
      @observer.observe document.body, "childList": true, "subtree": true
    else
      @observer = window.setInterval observe, 10000

  setupSyncTimeout: ->
    if @syncTimeout
      clearTimeout @syncTimeout
      @syncTimeout = null

    @syncTimeout = window.setTimeout(=>
      @syncEmail()
    , 60000)

  setupKeyboardHandler: ->
    @keyboardHandler = new TuringEmailAppKeyboardHandler(this)
    @keyboardHandler.start() if @models.userConfiguration.get("keyboard_shortcuts_enabled")

  setupMainView: (emailTemplatesJSON, uploadAttachmentPostJSON) ->
    @views.mainView = new TuringEmailApp.Views.Main(
      app: TuringEmailApp
      el: $("#main")
      emailTemplatesJSON: emailTemplatesJSON
      uploadAttachmentPostJSON: uploadAttachmentPostJSON
    )
    @views.mainView.render()

  setupToolbar: ->
    @views.toolbarView = @views.mainView.toolbarView

    @setupListeners(@views.toolbarView,
                    "checkAllClicked",
                    "checkAllReadClicked",
                    "checkAllUnreadClicked",
                    "uncheckAllClicked",
                    "readClicked",
                    "unreadClicked",
                    "trashClicked",
                    "snoozeClicked",
                    "archiveClicked",
                    "pauseClicked",
                    "createNewLabelClicked",
                    "createNewEmailFolderClicked",
                    "goBackClicked")

    @listenTo(@views.toolbarView, "labelAsClicked", (toolbarView, labelID) => @labelAsClicked(labelID))
    @listenTo(@views.toolbarView, "moveToFolderClicked", (toolbarView, folderID) => @moveToFolderClicked(folderID))
    @listenTo(@views.toolbarView, "searchClicked", (toolbarView, query) => @searchClicked(query))
    @listenTo(@views.mainView, "searchClicked", (mainView, query) => @searchClicked(query))

    @trigger("change:toolbarView", this, @views.toolbarView)

  setupUser: (userJSON, userConfigurationJSON) ->
    @models.user = new TuringEmailApp.Models.User(userJSON)
    @models.userConfiguration = new TuringEmailApp.Models.UserConfiguration(userConfigurationJSON)
    @models.userConfiguration.app = @

    @listenTo(@models.userConfiguration, "change:keyboard_shortcuts_enabled", =>
      if @models.userConfiguration.get("keyboard_shortcuts_enabled")
        @keyboardHandler.start()
      else
        @keyboardHandler.stop()
    )

  setupEmailFolders: ->
    @collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(undefined,
      app: TuringEmailApp
    )
    @views.emailFoldersTreeView = new TuringEmailApp.Views.TreeView(
      app: this
      el: $(".tm_email-folders")
      collection: @collections.emailFolders
    )

    @listenTo(@views.emailFoldersTreeView, "emailFolderSelected", @emailFolderSelected)

  setupEmailTrackers: ->
    @collections.emailTrackers = new TuringEmailApp.Collections.EmailTrackersCollection()

  setupAndLoadEmailAccounts: (emailAccountsJSON) ->
    @collections.emailAccounts = new TuringEmailApp.Collections.EmailAccountsCollection()
    if emailAccountsJSON
      @collections.emailAccounts.reset emailAccountsJSON.other_email_accounts
      @collections.emailAccounts.current_email_account = emailAccountsJSON.current_email_account
      @collections.emailAccounts.current_email_account_type = emailAccountsJSON.current_email_account_type

  setupEmailTemplateCategories: ->
    @collections.emailTemplateCategories = new TuringEmailApp.Collections.EmailTemplateCategoriesCollection()

  setupEmailTemplates: ->
    @collections.emailTemplates = new TuringEmailApp.Collections.EmailTemplatesCollection()

  setupComposeView: ->
    @views.composeView = @views.mainView.composeView

    @listenTo(@views.composeView, "change:draft", @draftChanged)
    @listenTo(@views.composeView, "archiveClicked", @archiveClicked)

  setupCreateFolderView: ->
    @views.createFolderView = @views.mainView.createFolderView

    @listenTo(@views.createFolderView, "createFolderFormSubmitted", (createFolderView, mode, folderName) => @createFolderFormSubmitted(mode, folderName))

  setupEmailThreads: ->
    @collections.emailThreads = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
      app: this
    )
    @views.emailThreadsListView = @views.mainView.createEmailThreadsListView(@collections.emailThreads)

    @listenTo(@views.emailThreadsListView, "listItemSelected", @listItemSelected)
    @listenTo(@views.emailThreadsListView, "listItemDeselected", @listItemDeselected)
    @listenTo(@views.emailThreadsListView, "listItemChecked", @listItemChecked)
    @listenTo(@views.emailThreadsListView, "listItemUnchecked", @listItemUnchecked)
    @listenTo(@views.emailThreadsListView, "listViewBottomReached", @listViewBottomReached)

  setupRouters: ->
    for k, v of TuringEmailApp.Routers
      routerName = k[0].toLowerCase() + k[1..]
      @routers[routerName] = new v

  ###############
  ### Getters ###
  ###############

  selectedEmailThread: ->
    return @views.emailThreadsListView.selectedItem()

  selectedEmailFolder: ->
    return @views.emailFoldersTreeView.selectedItem()

  selectedEmailFolderID: ->
    return @views.emailFoldersTreeView.selectedItem()?.get("label_id")

  currentRoute: ->
    window.location.hash

  currentRouteIsAnEmailFolder: ->
    @currentRoute().match /^#(search|email_folder|email_thread)/gi

  currentEmailAddress: ->
    @collections.emailAccounts.current_email_account

  ###############
  ### Setters ###
  ###############

  currentEmailThreadIs: (emailThreadUID=".", refresh=false) ->
    loadEmailThreadCallback = (emailThread) =>
      # Do short-circuit only when refresh is false
      return if not refresh and @currentEmailThreadView?.model is emailThread

      if @views.emailThreadsListView.collection.length is 0
        @currentEmailFolderIs emailThread.primaryEmailFolder(), 1

      @views.emailThreadsListView.select(emailThread, silent: true)
      @showEmailThread(emailThread)

      @views.toolbarView.uncheckAllCheckbox()

      @trigger "change:selectedEmailThread", this, emailThread

    # if refresh, reload the current email thread if exists
    if refresh
      loadEmailThreadCallback @currentEmailThreadView.model if @currentEmailThreadView?.model
    else if emailThreadUID != "."
      @loadEmailThread(emailThreadUID, loadEmailThreadCallback)
    else
      # do the show show first so then if the select below triggers this again it will exit above
      @showEmailThread()
      @views.emailThreadsListView.deselect()
      @views.toolbarView.uncheckAllCheckbox()

      @trigger "change:selectedEmailThread", this, null

  currentEmailFolderIs: (emailFolderID, pageTokenIndex, lastEmailThreadUID=null, dir="DESC") ->
    @searchQuery = undefined

    @collections.emailThreads.folderIDIs(emailFolderID)
    @collections.emailThreads.pageTokenIndexIs(parseInt(pageTokenIndex)) if pageTokenIndex?
    @collections.emailThreads.setupURL(lastEmailThreadUID, dir)

    reset = not pageTokenIndex?
    lastItem = @collections.emailThreads.last()

    @reloadEmailThreads(
      skipRender: true
      reset: reset

      success: (collection, response, options) =>
        emailFolder = @collections.emailFolders.get(emailFolderID)
        @views.emailFoldersTreeView.select(emailFolder, silent: true)
        @trigger("change:currentEmailFolder", this, emailFolder, @collections.emailThreads.pageTokenIndex + 1)

        @showEmails()
        @views.emailThreadsListView.scrollListItemIntoView(lastItem, "bottom") if !reset

        if pageTokenIndex?
          @currentEmailThreadIs null, true
        else if @isSplitPaneMode() && @collections.emailThreads.length > 0
          @currentEmailThreadIs(@collections.emailThreads.models[0].get("uid"))
    )

  ######################
  ### Sync Functions ###
  ######################

  syncEmail: ->
    reload = =>
      @reloadEmailThreads(
        query: @searchQuery
        skipRender: true
        reset: not @collections.emailThreads.pageTokenIndex?
      )
      @loadEmailFolders()

    $.post("api/v1/email_accounts/sync#{TuringEmailApp.Mixins.syncUrlQuery("?")}", undefined, undefined).done(
      (data) =>
        last_email_update = new Date(data)

        if not @last_email_update || last_email_update > @last_email_update
          @last_email_update = last_email_update
          reload()
    )

    @setupSyncTimeout()

  #######################
  ### Alert Functions ###
  #######################

  showAlert: (text, classType, removeAfterSeconds) ->
    @removeAlert(@currentAlert.token) if @currentAlert?

    @currentAlert = new TuringEmailApp.Views.AlertView(
      text: text
      classType: classType
    )
    @currentAlert.render()

    $(@currentAlert.el).prependTo('body').addClass('tm_alert-animated')

    token = @currentAlert.token
    setTimeout (=>
      @removeAlert(token)
    ), removeAfterSeconds if removeAfterSeconds?

    return @currentAlert.token

  removeAlert: (token) ->
    return if not @currentAlert? || @currentAlert.token != token
    $(@currentAlert.el).fadeOut('fast', ->
      $(@).remove()
    )
    @currentAlert = undefined

  ##############################
  ### Email Folder Functions ###
  ##############################

  loadEmailFolders: (emailFoldersJSON) ->
    # load from json, if json is provided
    if emailFoldersJSON
      @collections.emailFolders.reset emailFoldersJSON

      @trigger("change:emailFolders", @, @collections.emailFolders)
      @trigger("change:currentEmailFolder", @, @selectedEmailFolder(), @collections.emailThreads.pageTokenIndex + 1)
    else
      @collections.emailFolders.fetch(
        reset: true

        success: (collection, response, options) =>
          @trigger("change:emailFolders", this, collection)
          @trigger("change:currentEmailFolder", this, @selectedEmailFolder(), @collections.emailThreads.pageTokenIndex + 1)
      )

  ################################
  ### Tracked Emails Functions ###
  ################################

  loadEmailTrackers: (emailTrackersJSON) ->
    # load from json, if json is provided
    if emailTrackersJSON
      @collections.emailTrackers.reset emailTrackersJSON
    else
      @collections.emailTrackers.fetch(reset: true)

  ###########################################
  ### Email Template Categories Functions ###
  ###########################################

  loadEmailTemplateCategories: (emailTemplateCategoriesJSON) ->
    # load from json, if json is provided
    if emailTemplateCategoriesJSON
      @collections.emailTemplateCategories.reset emailTemplateCategoriesJSON
    else
      @collections.emailTemplateCategories.fetch(reset: true)

  ###########################################
  ### Email Template Categories Functions ###
  ###########################################

  loadEmailTemplates: (emailTemplatesJSON) ->
    # load from json, if json is provided
    if emailTemplatesJSON
      @collections.emailTemplates.reset emailTemplatesJSON
    else
      @collections.emailTemplates.fetch(reset: true)

  ##############################
  ### Email Thread Functions ###
  ##############################

  loadEmailThread: (emailThreadUID, callback) ->
    emailThread = @collections.emailThreads?.get(emailThreadUID)

    if emailThread?
      callback(emailThread)
    else
      emailThread = new TuringEmailApp.Models.EmailThread(undefined,
        app: TuringEmailApp
        emailThreadUID: emailThreadUID
      )
      emailThread.fetch(
        success: (model, response, options) ->
          callback?(emailThread)
      )

  reloadEmailThreads: (myOptions=skipRender: false, reset: true) ->
    selectedEmailThread = @selectedEmailThread()

    @views.emailThreadsListView.skipRender = myOptions.skipRender

    @collections.emailThreads.fetch(
      query: myOptions.query
      reset: myOptions.reset
      remove: myOptions.reset

      success: (collection, response, options) =>
        @views.emailThreadsListView.skipRender = false

        if options.previousModels?
          @stopListening(emailThread) for emailThread in options.previousModels

        for emailThread in collection.models
          @listenTo(emailThread, "change:seen", @emailThreadSeenChanged)
          @listenTo(emailThread, "change:folder", @emailThreadFolderChanged)

        if selectedEmailThread? && not @selectedEmailThread()?
          emailThreadToSelect = collection.get(selectedEmailThread.get("uid"))

          if emailThreadToSelect?
            @ignoreListItemSelected = true
            @views.emailThreadsListView.select(emailThreadToSelect)
            @ignoreListItemSelected = false

        @views.mainView.resize()
        myOptions.success(collection, response, options) if myOptions?.success?

      error: (collection, response, options) =>
        @views.emailThreadsListView.skipRender = false

        myOptions.error(collection, response, options) if myOptions?.error?
    )

  setupEmptySearchBar: ->
    @views.mainView.$el.find(".tm_mail-view .tm_search-field").submit (evt) =>
      evt.preventDefault()
      @views.toolbarView.$el.find(".tm_headbar-toolbar .tm_search-field input").val ""
      @searchClicked($(evt.target).find("input").val())
      @views.mainView.$el.find(".tm_mail-view").html("<div class='loader'><div class='line-spin-fade-loader'><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div></div><div class='tm_empty-pane'>Now Searching...</div>")

  loadSearchResults: (query, reset = true) ->
    @searchQuery = query
    @collections.emailThreads.resetPageTokenIndex() if reset

    lastItem = @collections.emailThreads.last()

    @reloadEmailThreads(
      query: query
      skipRender: true
      reset: reset

      success: (collection, response, options) =>
        @showEmails()
        @showSearchResultsAnimation(collection.length)
        @views.emailThreadsListView.scrollListItemIntoView(lastItem, "bottom") if !reset
    )

  applyActionToSelectedThreads: (singleAction, multiAction, remove=false, clearSelection=false, refreshFolders=false, moveSelection=false) ->
    checkedListItemViews = @views.emailThreadsListView.getCheckedListItemViews()

    if checkedListItemViews.length == 0
      selectedIndex = @views.emailThreadsListView.selectedIndex()
      singleAction()
      @collections.emailThreads.remove @selectedEmailThread() if remove
      (if @isSplitPaneMode() then @currentEmailThreadIs() else @goBackClicked()) if clearSelection and not moveSelection
      @views.emailThreadsListView.selectedIndexIs selectedIndex if moveSelection
    else
      selectedEmailThreads = []
      selectedEmailThreadUIDs = []

      for listItemView in checkedListItemViews
        selectedEmailThreads.push(listItemView.model)
        selectedEmailThreadUIDs.push(listItemView.model.get("uid"))

      multiAction(checkedListItemViews, selectedEmailThreadUIDs)

      @collections.emailThreads.remove selectedEmailThreads if remove

      (if @isSplitPaneMode() then @currentEmailThreadIs() else @goBackClicked()) if clearSelection

    @loadEmailFolders() if refreshFolders

  ######################
  ### General Events ###
  ######################

  checkAllClicked: ->
    @views.emailThreadsListView.checkAll()

  checkAllReadClicked: ->
    @views.emailThreadsListView.checkAllRead()

  checkAllUnreadClicked: ->
    @views.emailThreadsListView.checkAllUnread()

  uncheckAllClicked: ->
    @views.emailThreadsListView.uncheckAll()

  readClickedIs: (isRead) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.setSeen(isRead)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        @collections.emailThreads.emailThreadsSeenIs(selectedEmailThreadUIDs, isRead)

        for listItemView in checkedListItemViews
          listItemView.model.setSeen(isRead, silent: true)
          listItemView.uncheck()
          listItemView.removeCheckStyles()
      false, false
    )

  readClicked: ->
    @readClickedIs true
    @showAlert("Marked as read.", "alert-success", 5000) unless @emailThreadsListViewIsEmpty()

  unreadClicked: ->
    @readClickedIs false
    @showAlert("Marked as unread.", "alert-success", 5000) unless @emailThreadsListViewIsEmpty()

  labelAsClicked: (labelID, labelName) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.applyGmailLabel(labelID, labelName)
      (checkedListItemViews, selectedEmailThreadUIDs) ->
        TuringEmailApp.Models.EmailThread.applyGmailLabel(TuringEmailApp, selectedEmailThreadUIDs, labelID, labelName)
      false, false
    )
    @showAlert("Labeled.", "alert-success", 5000) unless @emailThreadsListViewIsEmpty()

  moveToFolderClicked: (folderID, folderName) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.moveToFolder(folderID, folderName)
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        for emailThreadUID in selectedEmailThreadUIDs
          @collections.emailThreads.get(emailThreadUID).moveToFolder(folderID, folderName)
      true, true, true, true
    )
    @showAlert("Moved to folder.", "alert-success", 5000) unless @emailThreadsListViewIsEmpty()

  pauseClicked: ->
    clearTimeout(@syncTimeout)
    @syncTimeout = null
    @showAlert("Email sync paused.", "alert-success", 5000)

  searchClicked: (query) ->
    if query
      @routers.searchResultsRouter.navigate("#search/" + query, trigger: true)
    else
      @routers.emailFoldersRouter.navigate("#email_folder/INBOX", trigger: true)


  goBackClicked: ->
    @routers.emailFoldersRouter.showFolder(@selectedEmailFolderID())

  responseClicked: (responseType) ->
    return false if not @selectedEmailThread()?

    @showEmailEditorWithEmailThread(@selectedEmailThread().get("uid"), responseType)
    return @selectedEmailThread()

  replyClicked: ->
    @responseClicked "reply"

  replyToAllClicked: ->
    @responseClicked "reply-to-all"

  forwardClicked: ->
    @responseClicked "forward"

  archiveClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.removeFromFolder(@selectedEmailFolderID())
      (checkedListItemViews, selectedEmailThreadUIDs) =>
        TuringEmailApp.Models.EmailThread.removeFromFolder(TuringEmailApp, selectedEmailThreadUIDs, @selectedEmailFolderID())
      true, true, true, true
    )
    @showAlert("Archived.", "alert-success", 5000) unless @emailThreadsListViewIsEmpty()

  trashClicked: ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.trash()
      (checkedListItemViews, selectedEmailThreadUIDs) ->
        TuringEmailApp.Models.EmailThread.trash(TuringEmailApp, selectedEmailThreadUIDs)
      true, true, true, true
    )
    @showAlert("Deleted.", "alert-success", 5000) unless @emailThreadsListViewIsEmpty()

  snoozeClicked: (view, minutes) ->
    @applyActionToSelectedThreads(
      =>
        @selectedEmailThread()?.snooze(minutes)
      (checkedListItemViews, selectedEmailThreadUIDs) ->
        TuringEmailApp.Models.EmailThread.snooze(TuringEmailApp, selectedEmailThreadUIDs, minutes)
      true, true, true, true
    )
    @showAlert("Snoozed.", "alert-success", 5000) unless @emailThreadsListViewIsEmpty()

  createNewLabelClicked: ->
    @views.createFolderView.show("label")

  createNewEmailFolderClicked: ->
    @views.createFolderView.show("folder")

  installAppClicked: (view, appID) ->
    TuringEmailApp.Models.App.Install(appID)
    @models.userConfiguration.fetch(reset: true)

  uninstallAppClicked: (view, appID) ->
    TuringEmailApp.Models.InstalledApps.InstalledApp.Uninstall(appID)
    @models.userConfiguration.fetch(reset: true)

  #############################
  ### EmailThreads.ListView ###
  #############################

  listItemSelected: (listView, listItemView) ->
    return if @ignoreListItemSelected? && @ignoreListItemSelected

    emailThread = listItemView.model
    emailThreadUID = emailThread.get("uid")

    @routers.emailThreadsRouter.navigate("#email_thread/" + emailThreadUID, trigger: true)

  listItemDeselected: (listView, listItemView) ->
    @routers.emailThreadsRouter.navigate("#email_thread/.", trigger: true)

  listItemChecked: (listView, listItemView) ->
    @currentEmailThreadView.$el.hide() if @currentEmailThreadView

  listItemUnchecked: (listView, listItemView) ->
    if @views.emailThreadsListView.getCheckedListItemViews().length is 0
      @currentEmailThreadView.$el.show() if @currentEmailThreadView

  listViewBottomReached: (listView) ->
    @tryToLoadMoreEmailThreadsInFolder()

  tryToLoadMoreEmailThreadsInFolder: ->
    if @collections.emailThreads.hasNextPage()
      if not @searchQuery?
        url = "#email_folder/" + @selectedEmailFolderID()
        url += "/" + (@collections.emailThreads.pageTokenIndex + 1)
        url += "/" + @collections.emailThreads.last().get("uid") + "/DESC"

        @routers.emailFoldersRouter.navigate(url, trigger: true)
      else
        if @collections.emailThreads.hasNextPage()
          @collections.emailThreads.pageTokenIndexIs(@collections.emailThreads.pageTokenIndex + 1)
          @loadSearchResults(@searchQuery, false)

  ####################################
  ### EmailFolders.TreeView Events ###
  ####################################

  emailFolderSelected: (treeView, emailFolder) ->
    return if not emailFolder?

    emailFolderID = emailFolder.get("label_id")

    emailFolderURL = "#email_folder/" + emailFolderID
    if window.location.hash is emailFolderURL
      @routers.emailFoldersRouter.showFolder(emailFolderID)
    else
      @routers.emailFoldersRouter.navigate("#email_folder/" + emailFolderID, trigger: true)

  ##########################
  ### ComposeView Events ###
  ##########################

  draftChanged: (composeView, draft, emailThreadParent) ->
    if emailThreadParent?
      emails = _.clone(emailThreadParent.get("emails"))

      for index in [emails.length-1 .. 0]
        email = emails[index]

        if email["draft_id"] == draft.get("draft_id")
          emails.splice(index, 1)
          break

      emails.push(draft.toJSON())
      emailThreadParent.set("emails", emails)

    @reloadEmailThreads()
    @loadEmailFolders()

  ###############################
  ### CreateFolderView Events ###
  ###############################

  createFolderFormSubmitted: (mode, folderName) ->
    if mode == "label"
      @labelAsClicked undefined, folderName
    else
      @moveToFolderClicked undefined, folderName

  ##########################
  ### EmailThread Events ###
  ##########################

  emailThreadSeenChanged: (emailThread, seenValue) ->
    delta = if seenValue then -1 else 1

    for folderID in emailThread.get("folder_ids")
      folder = @collections.emailFolders.get(folderID)
      continue if not folder?

      folder.set("num_unread_threads", folder.get("num_unread_threads") + delta)
      @trigger("change:emailFolderUnreadCount", this, folder)

  emailThreadFolderChanged: (emailThread, newFolder) ->
    folder = @collections.emailFolders.get(newFolder["label_id"])

    @loadEmailFolders() if not folder?

  ######################
  ### View Functions ###
  ######################

  isSplitPaneMode: ->
    splitPaneMode = @models.userConfiguration.get("split_pane_mode")
    return (splitPaneMode is "horizontal" || splitPaneMode is "vertical") and !isMobile()

  emailThreadsListViewIsEmpty: ->
    @views.emailThreadsListView.collection.length is 0

  showEmailThread: (emailThread) ->
    emailThreadView = @views.mainView.showEmailThread(emailThread, @isSplitPaneMode())

    @listenTo(emailThreadView, "goBackClicked", @goBackClicked)
    @listenTo(emailThreadView, "replyClicked", @replyClicked)
    @listenTo(emailThreadView, "replyToAllClicked", @replyToAllClicked)
    @listenTo(emailThreadView, "forwardClicked", @forwardClicked)
    @listenTo(emailThreadView, "archiveClicked", @archiveClicked)
    @listenTo(emailThreadView, "trashClicked", @trashClicked)
    @listenTo(emailThreadView, "sendClicked", @sendClicked)

    if @currentEmailThreadView?
      @stopListening(@currentEmailThreadView)
      @currentEmailThreadView.stopListening()

    @currentEmailThreadView = emailThreadView

  showEmailEditorWithEmailThread: (emailThreadUID, mode="draft") ->
    @loadEmailThread(emailThreadUID, (emailThread) =>
      @currentEmailThreadIs emailThread.get("uid")

      emails = emailThread.get("emails")

      @views.composeView.show() if isMobile()

      switch mode
        when "forward"
          @views.composeView.loadEmailAsForward(_.last(emails), emailThread)
          $('.compose-modal').removeClass 'modal-left modal-right modal-bottom modal-top'
          $('.compose-modal').addClass 'modal-left'
        when "reply"
          @views.composeView.loadEmailAsReply(_.last(emails), emailThread)
          $('.compose-modal').removeClass 'modal-left modal-right modal-bottom modal-top'
          $('.compose-modal').addClass 'modal-top'
        when "reply-to-all"
          @views.composeView.loadEmailAsReplyToAll(_.last(emails), emailThread)
          $('.compose-modal').removeClass 'modal-left modal-right modal-bottom modal-top'
          $('.compose-modal').addClass 'modal-top'
        else
          @views.composeView.loadEmailDraft(_.last(emails), emailThread)
          $('.compose-modal').removeClass 'modal-left modal-right modal-bottom modal-top'
          $('.compose-modal').addClass 'modal-top'

      @views.composeView.show() if not isMobile()

      @views.composeView.loadEmailSignature()
    )

  showEmailEditorWithEmail: (emailJSON, mode) ->
    switch mode
      when "forward"
        @views.composeView.loadEmailAsForward(emailJSON, null)
      when "reply"
        @views.composeView.loadEmailAsReply(emailJSON, null)

    @views.composeView.show()

  sendClicked: (address) ->
    @views.composeView.show()
    @views.composeView.email.set "tos" : [address]

  showEmails: ->
    @views.mainView.showEmails(@isSplitPaneMode())

  showAppsLibrary: ->
    @stopListening(@appsLibraryView) if @appsLibraryView

    @appsLibraryView = @views.mainView.showAppsLibrary()
    @listenTo(@appsLibraryView, "installAppClicked", @installAppClicked)

  showScheduleEmails: ->
    @scheduleEmailsView = @views.mainView.showScheduleEmails()

  showEmailReminders: ->
    @views.mainView.showEmailReminders()

  showEmailAttachments: ->
    @views.mainView.showEmailAttachments()

  showEmailTrackers: ->
    @views.mainView.showEmailTrackers()

  showEmailSignatures: ->
    @views.mainView.showEmailSignatures()

  showEmailTemplates: (emailTemplateCategoryUID) ->
    @views.mainView.showEmailTemplates(emailTemplateCategoryUID)

  showEmailTemplateCategories: ->
    @views.mainView.showEmailTemplateCategories()

  showListSubscriptions: ->
    @stopListening(@listSubscriptionsView) if @listSubscriptionsView

    @listSubscriptionsView = @views.mainView.showListSubscriptions()

  showInboxCleaner: ->
    @inboxCleanerView = @views.mainView.showInboxCleaner()

  showInboxCleanerReport: ->
    @inboxCleanerReportView = @views.mainView.showInboxCleanerReport()

  showCompose: ->
    @views.mainView.compose()

  showContactInbox: ->
    @views.mainView.showContactInbox()

  showWelcomeTour: ->
    @views.mainView.showWelcomeTour()
    @routers.emailFoldersRouter.navigate("#email_folder/INBOX", trigger: true)

  showAbout: ->
    @views.mainView.showAbout()

  showFAQ: ->
    @views.mainView.showFAQ()

  showPrivacy: ->
    @views.mainView.showPrivacy()

  showTerms: ->
    @views.mainView.showTerms()

  showSettings: ->
    @models.userConfiguration.fetch(reset: true)

    @stopListening(@settingsView) if @settingsView

    @settingsView = @views.mainView.showSettings()
    @listenTo(@settingsView, "uninstallAppClicked", @uninstallAppClicked)

  showDashboard: ->
    @views.mainView.showDashboard()

  showFilters: ->
    @views.mainView.showFilters()

  showAnalytics: ->
    @views.mainView.showAnalytics()

  showReport: (ReportModel, ReportView) ->
    @views.mainView.showReport(ReportModel, ReportView)

  ##################
  ### Animations ###
  ##################

  showSearchResultsAnimation: (numSearchResults) ->
    if numSearchResults is 0
      @views.mainView.$el.find(".tm_mail-view").html("<div class='tm_empty-pane'><div>Your search had no results.<br /><small>0 Emails Found</small><form class='tm_search-field' role='search'><input class='tm_input tm_input-rounded' type='search' name='search' placeholder='Search Again' value=''><div class='tm_search-field-buttons'><button type='reset'><svg class='icon'><use xlink:href='/images/symbols.svg#reset'></use></svg></button> <button type='submit'><svg class='icon'><use xlink:href='/images/symbols.svg#search'></use></svg></button></div></form></div></div>")
      @views.mainView.$el.find(".tm_mail-box").html("")
      @setupEmptySearchBar()
    else
      @views.mainView.$el.find(".tm_mail-view").html("<div class='tm_empty-pane'><div>Your search is complete.<br /><small>" + numSearchResults + " Email#{if numSearchResults > 1 then 's' else ''} Found</small></div></div>")

  ######################
  ### Misc Functions ###
  ######################

  # TODO write tests
  downloadFile: (url) ->
    if not @downloadIframe
      @downloadIframe = $("<iframe></iframe>").appendTo("body")[0]
      @downloadIframe.hidden = true

    @downloadIframe.src = url

  refreshPane: (splitMode) ->
    windowLocationHash = window.location.hash.toString()

    if /^(#email_folder)/.test windowLocationHash
      @showEmails()

      # select the current email thread only when horizontal or vertical mode
      @currentEmailThreadIs null, true if splitMode is "horizontal" or splitMode is "vertical"
    else if /^(#email_thread)/.test windowLocationHash
      @showEmails()
      @currentEmailThreadIs null, true

))(el: document.body)

TuringEmailApp.tattletale = new Tattletale('/api/v1/log.json')

$(document).ajaxError((event, jqXHR, ajaxSettings, thrownError) ->
  TuringEmailApp.tattletale.log(JSON.stringify(jqXHR))
  TuringEmailApp.tattletale.send()
)

window.onerror = (message, url, lineNumber, column, errorObj) ->
  #save error and send to server for example.
  TuringEmailApp.tattletale.log(JSON.stringify(message))
  TuringEmailApp.tattletale.log(JSON.stringify(url.toString()))
  TuringEmailApp.tattletale.log(JSON.stringify("Line number: " + lineNumber.toString()))

  if errorObj?
    TuringEmailApp.tattletale.log(JSON.stringify(errorObj.stack))

  TuringEmailApp.tattletale.send()
