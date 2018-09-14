TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Settings ||= {}

class TuringEmailApp.Views.PrimaryPane.Settings.SettingsView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/primary_pane/settings"]

  className: "tm_content tm_settings-view"

  initialize: (options) ->
    super(options)

    @app = options.app

    @listenTo(@model, "change", @render)
    @listenTo(@model, "destroy", @remove)

  render: ->
    selectedTabID = $(".tm_content-tab-pane.active").attr("id")

    @$el.html(@template({
      name: @app.models.user.get("name")
      profilePicture: if @app.models.user.get("profile_picture")? then @app.models.user.get("profile_picture") else false
      userConfiguration: @model.toJSON()
    }))

    @setupSwitches()
    @setupProfilePane()

    $("a[href=#" + selectedTabID + "]").click() if selectedTabID?

    $(".mobile-toolbar-settings").show().siblings().hide()

    @

  setupSwitches: ->
    @$(".keyboard-shortcuts-switch").bootstrapSwitch()
    @$(".inbox-tabs-switch").bootstrapSwitch()
    @$(".context-sidebar-switch").bootstrapSwitch()

    @$(".keyboard-shortcuts-switch, .inbox-tabs-switch, .context-sidebar-switch").
         on("switch-change", (evt, state) =>
      @saveSettings()
    )

    @$(".split-pane-select").change(=>
      @saveSettings()
      split_pane_mode = @$(".split-pane-select").val()
      if TuringEmailApp.views.mainView.splitPaneLayout?
        TuringEmailApp.views.mainView.splitPaneLayout.state.south.size = 0.5 if split_pane_mode is "horizontal"
        TuringEmailApp.views.mainView.splitPaneLayout.state.east.size = 0.75 if split_pane_mode is "vertical"
    )

  saveSettings: (refresh=false) ->
    keyboard_shortcuts_enabled = @$(".keyboard-shortcuts-switch").parent().parent().hasClass("switch-on")
    split_pane_mode = @$(".split-pane-select").val()
    inbox_tabs_enabled = @$(".inbox-tabs-switch").parent().parent().hasClass("switch-on")
    context_sidebar_enabled = @$(".context-sidebar-switch").parent().parent().hasClass("switch-on")

    @model.set({
      split_pane_mode: split_pane_mode,
      keyboard_shortcuts_enabled: keyboard_shortcuts_enabled,
      inbox_tabs_enabled: inbox_tabs_enabled,
      context_sidebar_enabled: context_sidebar_enabled
    })

    @model.save(null, {
      patch: true
      success: (model, response) ->
        location.reload() if refresh
        TuringEmailApp.showAlert("You have successfully saved your settings!", "alert-success", 5000)
      }
    )

  setupProfilePane: ->
    usernameInput = @$(".tm_input.tm_settings-username")

    usernameInput.focusout =>
      @updateProfile()

    usernameInput.keyup (e) =>
      @updateProfile() if e.keyCode == 13

  updateProfile: ->
    user = TuringEmailApp.models.user
    user.url = "/api/v1/users/update"
    name = @$(".tm_input.tm_settings-username").val()

    user.set({
      name: name
    })

    user.save(null, {
      patch: true
      type: "PATCH"
      success: (model, response) ->
        TuringEmailApp.showAlert("You have successfully updated your user profile!", "alert-success", 5000)
        TuringEmailApp.views.toolbarView.render()
      }
    )
