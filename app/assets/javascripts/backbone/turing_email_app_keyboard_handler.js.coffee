class @TuringEmailAppKeyboardHandler
  constructor: (@app) ->
    @handlers =
      "keydown":
        "up": (evt) => @moveSelectionUp(evt)
        "down": (evt) => @moveSelectionDown(evt)
        
        "K": (evt) => @moveSelectionUp(evt)
        "J": (evt) => @moveSelectionDown(evt)
        
        "C": (evt) => @showCompose(evt)

        "R": (evt) => @showReply(evt)
        "F": (evt) => @showForward(evt)
        
        "E": (evt) => @archiveEmail(evt)
        "Y": (evt) => @archiveEmail(evt)

        "V": (evt) => @showMoveToFolderMenu(evt)
    
  start: ->
    this.bindKeys()
    
  stop: ->
    this.unbindKeys()

  bindKeys: ->
    for type, typeHandlers of @handlers
      $(document).on(type, null, keys, callback) for keys, callback of typeHandlers

  unbindKeys: ->
    for type, typeHandlers of @handlers
      $(document).off(type, callback) for keys, callback of typeHandlers

  moveSelectionUp: (evt) ->
    return unless @app.currentRouteIsAnEmailFolder()

    evt.preventDefault()

    @app.views.mainView.emailThreadsListView.moveSelectionUp()

  moveSelectionDown: (evt) ->
    return unless @app.currentRouteIsAnEmailFolder()

    evt.preventDefault()

    @app.views.mainView.emailThreadsListView.moveSelectionDown()

  showCompose: (evt) ->
    evt.preventDefault()

    @app.views.mainView.compose()

  showReply: (evt) ->
    evt.preventDefault()

    if @app.currentRouteIsAnEmailFolder() then @app.replyClicked() else @showCompose(evt)

  showForward: (evt) ->
    evt.preventDefault()

    if @app.currentRouteIsAnEmailFolder() then @app.forwardClicked() else @showCompose(evt)

  archiveEmail: (evt) ->
    return unless @app.currentRouteIsAnEmailFolder()

    evt.preventDefault()

    @app.archiveClicked()

  showMoveToFolderMenu: (evt) ->
    return unless @app.currentRouteIsAnEmailFolder()

    evt.preventDefault()

    @app.views.toolbarView.showMoveToFolderMenu()
