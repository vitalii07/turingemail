class TuringEmailApp.Models.UserConfiguration extends TuringEmailApp.Models.BaseModel
  @EmailThreadsPerPage: 30

  url: "/api/v1/user_configurations"

  validation:
    automatic_inbox_cleaner_enabled:
      required: true
      acceptance: true

    split_pane_mode:
      required: true

    keyboard_shortcuts_enabled:
      required: true
      acceptance: true

    auto_cleaner_enabled:
      required: true
      acceptance: true

    id:
      required: true

    installed_apps:
      required: true
      isArray: true

  inboxTabsIsEnabled: ->
    @get("inbox_tabs_enabled") and not isMobile() and @app.collections.emailAccounts.currentEmailAccountIsAGmailAccount()
