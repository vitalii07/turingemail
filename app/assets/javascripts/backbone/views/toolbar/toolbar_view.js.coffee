class TuringEmailApp.Views.ToolbarView extends TuringEmailApp.Views.RactiveView
  @MAX_RETRY_ATTEMPTS: 5

  template: JST["backbone/templates/toolbar/toolbar"]
  tagName: "div"

  data: ->
    _.extend {}, super(),
      "static":
        emailFolders: (=>
          emailFolders = @currentEmailFolders?.toJSON() ? []

          _.sortBy(emailFolders, (emailFolder) ->
            emailFolder.name
          ))()
        userAddress: @app.collections.emailAccounts.current_email_account
        name: @app.models.user.get("name")
        profilePicture: if @app.models.user.get("profile_picture")? then @app.models.user.get("profile_picture") else false
        emailAccounts: @app.collections.emailAccounts.toJSON()
      "dynamic":
        primaryPaneTitle: @primaryPaneTitle || ""
        searchQuery: @app.searchQuery
        splitPaneModes: @splitPaneModes

  initialize: (options) ->
    super(options)

    @app = options.app
    @currentEmailFolders = options.emailFolders if options.emailFolders?

    @listenTo(options.app, "change:currentEmailFolder", @currentEmailFolderChanged)
    @listenTo(options.app, "change:emailFolders", @emailFoldersChanged)

    @$el.addClass("tm_headbar")

  render: ->
    @splitPaneModes = [
      {
        name: "Horizontal"
        value: "horizontal"
        icon: "split-horizontal"
      }
      {
        name: "Vertical"
        value: "vertical"
        icon: "split-vertical"
      }
      {
        name: "None"
        value: "off"
        icon: "split-none"
      }
    ]

    super()

    @setupAllCheckbox()
    @divAllCheckbox = @$("div.icheckbox")

    @setupButtons()
    @setupMobileButtons()

    if @currentEmailFolder?
      @updatePaginationText(@currentEmailFolder, @currentEmailFolderPage)

    $(".tooltip").remove()

    @setupSplitModeButton()
    @setupSearchBar()

    @setupMobileMenuBar()

    @

  resetSearchQuery: ->
    @app.searchQuery = ""

    @ractive?.set
      searchQuery: @app.searchQuery

  #######################
  ### Setup Functions ###
  #######################

  setupSplitModeButton: ->
    # Select the current selected pane mode
    currentMode = @app.models.userConfiguration.get "split_pane_mode"
    @$(".split-mode-btn-group button[data-split-mode='#{currentMode}']").addClass "pressed"

    # Add handler
    @$(".split-mode-btn-group").on "click", "button", (evt) =>
      $button = $(evt.currentTarget)
      $button.addClass "pressed"
      $button.siblings().removeClass "pressed"

      selectedMode = $button.data("split-mode")
      currentMode = @app.models.userConfiguration.get "split_pane_mode"

      if selectedMode != currentMode
        @app.models.userConfiguration.set split_pane_mode: selectedMode
        @app.models.userConfiguration.save null, patch: true

        if @app.views.mainView.splitPaneLayout?
          @app.views.mainView.splitPaneLayout.state.south.size = 0.5 if selectedMode is "horizontal"
          @app.views.mainView.splitPaneLayout.state.east.size = 0.75 if selectedMode is "vertical"

        @app.refreshPane selectedMode


  #TODO write tests
  setupSearchBar: ->
    @$(".tm_search-field").submit (evt) =>
      evt.preventDefault()
      @app.views.mainView.$el.find(".tm_mail-view").html("<div class='loader'><div class='line-spin-fade-loader'><div></div><div></div><div></div><div></div><div></div><div></div><div></div><div></div></div></div><div class='tm_empty-pane'>Now Searching...</div>")
      @app.searchClicked(@ractive.get("searchQuery"))
    @$(".tm_search-field").on "click", "button[type='reset']", (evt) =>
      evt.preventDefault()
      @resetSearchQuery()
      @$(".tm_search-field").submit()

  setupAllCheckbox: ->
    @$(".i-checks").iCheck
      checkboxClass: "icheckbox"
      radioClass: "iradio"

    @$("div.icheckbox ins").click =>
      if @allCheckboxIsChecked()
        @trigger("checkAllClicked", this)
      else
        @trigger("uncheckAllClicked", this)

  setupButtons: ->
    @setupBulkActionButtons()
    @setupSnoozeButtons()

    @$(".mark_as_read").click =>
      @trigger("readClicked", this)

    @$(".mark_as_unread").click =>
      @trigger("unreadClicked", this)

    @$(".archive-button").click =>
      @trigger("archiveClicked", this)

    @$(".trash-button").click =>
      @trigger("trashClicked", this)

    @$(".dropdown.label-as").hide() if not @app.collections.emailAccounts.currentEmailAccountIsAGmailAccount()

    @$(".label_as_link").click (evt) =>
      @$(".label_as_link").tooltip('hide')
      @trigger("labelAsClicked", this, $(evt.target).attr("name"))

    @$(".createNewLabel").click =>
      @$(".createNewLabel").tooltip('hide')
      @trigger("createNewLabelClicked", this)

    @$(".move_to_folder_link").click (evt) =>
      @$(".move_to_folder_link").tooltip('hide')
      @trigger("moveToFolderClicked", this, $(evt.target).attr("name"))

    @$(".createNewEmailFolder").click =>
      @$(".createNewEmailFolder").tooltip('hide')
      @trigger("createNewEmailFolderClicked", this)

    @$("[data-toggle=tooltip]").tooltip
      container: "body"

    # @$(".pause-button").click =>
    #   @trigger("pauseClicked", this)

  setupMobileButtons: ->
    @$(".mobile-compose-button").click =>
      @app.views.mainView.compose()

    if !TuringEmailApp.isSplitPaneMode()
      @$(".email-back-button").click =>
        @trigger("goBackClicked", this)

  setupBulkActionButtons: ->
    @$(".all-bulk-action").click =>
      @divAllCheckbox.iCheck("check")
      @trigger("checkAllClicked", this)

    @$(".none-bulk-action").click =>
      @divAllCheckbox.iCheck("uncheck")
      @trigger("uncheckAllClicked", this)

    @$(".read-bulk-action").click =>
      @trigger("checkAllReadClicked", this)

    @$(".unread-bulk-action").click =>
      @trigger("checkAllUnreadClicked", this)

  setupSnoozeButtons: ->
    @$(".snooze-dropdown .dropdown-menu .one-hour").click =>
      @$(".snooze-dropdown-menu").tooltip('hide')
      @trigger("snoozeClicked", this, 60)

    @$(".snooze-dropdown .dropdown-menu .four-hours").click =>
      @$(".snooze-dropdown-menu").tooltip('hide')
      @trigger("snoozeClicked", this, 60 * 4)

    @$(".snooze-dropdown .dropdown-menu .eight-hours").click =>
      @$(".snooze-dropdown-menu").tooltip('hide')
      @trigger("snoozeClicked", this, 60 * 8)

    @$(".snooze-dropdown .dropdown-menu .one-day").click =>
      @$(".snooze-dropdown-menu").tooltip('hide')
      @trigger("snoozeClicked", this, 60 * 24)

  setupMobileMenuBar: ->
    @$(".mobile-toolbar-menu-trigger").click ->
      $("body").toggleClass("sidebar-open")
      $("body").removeClass("right-sidebar-open usermenu-sidebar-open")

      pageHeader = $(".tm_mobile-page-header")
      if($("body").hasClass("sidebar-open"))
        pageHeader.data('title', pageHeader.text())
        pageHeader.text('Turing')
      else
        pageHeader.text(pageHeader.data('title'))
        pageHeader.data('title', null)

    @$(".mobile-toolbar-menu-right-trigger").click ->
      $("body").toggleClass("right-sidebar-open")
      $("body").removeClass("sidebar-open usermenu-sidebar-open")

    @$(".mobile-toolbar-usermenu-trigger").click ->
      $("body").toggleClass("usermenu-sidebar-open")
      $("body").removeClass("sidebar-open right-sidebar-open")

  #################
  ### Functions ###
  #################

  allCheckboxIsChecked: ->
    return @divAllCheckbox.hasClass "checked"

  uncheckAllCheckbox: ->
    @divAllCheckbox?.iCheck("uncheck")

  updatePaginationText: (emailFolder, page) ->
    if emailFolder? && page?
      numThreads = emailFolder.get("num_threads")

      firstThreadNumber = if numThreads is 0 then 0 else (page - 1) * TuringEmailApp.Models.UserConfiguration.EmailThreadsPerPage + 1

      lastThreadNumber = page * TuringEmailApp.Models.UserConfiguration.EmailThreadsPerPage
      lastThreadNumber = numThreads if lastThreadNumber > parseInt(numThreads)
    else
      numThreads = 0
      firstThreadNumber = 0
      lastThreadNumber = 0

    @$(".total-emails-number").html(numThreads)

  showMoveToFolderMenu: ->
    @$(".move-to-folder-dropdown-menu").trigger("click.bs.dropdown")

  #############################
  ### TuringEmailApp Events ###
  #############################

  currentEmailFolderChanged: (app, emailFolder, page) ->
    @currentEmailFolder = emailFolder
    @currentEmailFolderPage = page

    @updatePaginationText(emailFolder, page)

  emailFoldersChanged: (app, emailFolders) ->
    @currentEmailFolders = emailFolders
    @render()
