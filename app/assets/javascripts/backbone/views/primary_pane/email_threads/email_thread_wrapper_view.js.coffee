TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailThreads ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailThreads.EmailThreadWrapperView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_threads/email_threads_wrapper"]

  className: "tm_mail-box"

  data: ->
    _.extend {}, super(),
      "static":
        emailFolders: (=>
          emailFolders = @currentEmailFolders?.toJSON() ? []

          _.sortBy(emailFolders, (emailFolder) ->
            emailFolder.name
          ))()
        inbox_tabs_enabled: @app.models.userConfiguration.inboxTabsIsEnabled()
        emailFolderID: @app.selectedEmailFolderID()
      "dynamic":
        searchQuery: @app.searchQuery

  initialize: (options) ->
    super(options)

    @app = options.app
    @currentEmailFolders = TuringEmailApp.collections.emailFolders

  render: ->
    super()

    @setupSearchBar()
    @setupMobileSelectMode()

    @

  setupSearchBar: ->
    @$(".tm_search-field-mobile").submit (evt) =>
      evt.preventDefault()
      @app.searchClicked(@ractive.get("searchQuery"))

  resetSearchQuery: ->
    @app.searchQuery = ""

    @ractive?.set
      searchQuery: @app.searchQuery

  setupMobileSelectMode: ->
    @$(".thread-select-toggle").click (evt) =>
      @$el.addClass "thread-select-mode"

    @$(".thread-select-cancel").click (evt) =>
      @$el.removeClass "thread-select-mode"

    @$(".archive-button").click =>
      @app.archiveClicked()

    @$(".trash-button").click =>
      @app.trashClicked()

    @$(".move_to_folder_link").click (evt) =>
      @app.moveToFolderClicked($(evt.target).attr("name"))
