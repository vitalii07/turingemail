describe "SettingsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @server = sinon.fakeServer.create()

    @userConfiguration = new TuringEmailApp.Models.UserConfiguration()

    @settingsDiv = $("<div />", {id: "settings"}).appendTo("body")
    @settingsView = new TuringEmailApp.Views.PrimaryPane.Settings.SettingsView(
      app: TuringEmailApp
      el: @settingsDiv
      model: @userConfiguration
    )

    @userConfiguration.set(FactoryGirl.create("UserConfiguration"))

  afterEach ->
    @server.restore()
    @settingsDiv.remove()

    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@settingsView.template).toEqual JST["backbone/templates/primary_pane/settings"]

  describe "#render", ->
    it "renders the settings view", ->
      expect(@settingsDiv).toContainHtml('Keyboard Shortcuts')
      expect(@settingsDiv).toContainHtml('Preview Panel')
      expect(@settingsDiv).toContainHtml('Inbox Tabs')

    it "renders the tabs", ->
      expect(@settingsDiv.find("a[href=#tab-1]").text()).toEqual("General")
      expect(@settingsDiv.find("a[href=#tab-2]").text()).toEqual("Profile")

    it "renders the keyboard shortcuts switch", ->
      keyboardShortcutsSwitch = $(".keyboard-shortcuts-switch")
      expect(@settingsDiv).toContain(keyboardShortcutsSwitch)
      expect(keyboardShortcutsSwitch.is(":checked")).toEqual(@userConfiguration.get("keyboard_shortcuts_enabled"))

    it "renders the split pane select", ->
      splitPaneSelect = $(".split-pane-select")
      expect(@settingsDiv).toContain(splitPaneSelect)

    it "renders the inbox tabs switch", ->
      inboxTabsSwitch = $(".inbox-tabs-switch")
      expect(@settingsDiv).toContain(inboxTabsSwitch)
      expect(inboxTabsSwitch.is(":checked")).toEqual(@userConfiguration.get("inbox_tabs_enabled"))

    describe "with selected tab", ->
      beforeEach ->
        @selectedTabID = "#tab-2"
        @selector = "a[href=" + @selectedTabID + "]"
        $(@selector).click()

        @newSelectedTabID = $(".tm_content-tabs li.active a").attr("href")

      afterEach ->
        @selectedTabID = "#tab-1"
        @selector = "a[href=" + @selectedTabID + "]"
        $(@selector).click()

      it "selects the tab", ->
        expect(@newSelectedTabID).toEqual(@selectedTabID)

  describe "#setupSwitches", ->
    beforeEach ->
      @settingsView.setupSwitches()

    it "sets up the keyboard shortcuts switch", ->
      expect(@settingsDiv.find(".keyboard-shortcuts-switch").parent().parent()).toHaveClass "has-switch"

    it "sets up the inbox tabs switch", ->
      expect(@settingsDiv.find(".inbox-tabs-switch").parent().parent()).toHaveClass "has-switch"

  describe "#saveSettings", ->
    it "is called by the switch change event on the switches", ->
      spy = sinon.spy(@settingsView, "saveSettings")

      inboxTabsSwitch = @settingsView.$el.find(".inbox-tabs-switch")
      inboxTabsSwitch.click()
      expect(spy).toHaveBeenCalled()
      spy.restore()

    describe "when saveSettings is called", ->
      it "patches the server", ->
        inboxTabsSwitch = @settingsView.$el.find(".inbox-tabs-switch")
        inboxTabsSwitch.click()

        request = @server.requests[@server.requests.length - 1]

        expect(request.method).toEqual "PATCH"
        expect(request.url).toEqual "/api/v1/user_configurations"

      it "updates the user settings model with the correct values", ->
        expect(@userConfiguration.get("keyboard_shortcuts_enabled")).toEqual(true)
        expect(@userConfiguration.get("inbox_tabs_enabled")).toEqual(false)

        inboxTabsSwitch = $(".inbox-tabs-switch")
        inboxTabsSwitch.click()

        expect(@userConfiguration.get("keyboard_shortcuts_enabled")).toEqual(true)
        expect(@userConfiguration.get("inbox_tabs_enabled")).toEqual(true)

      it "displays a success alert after the save button is clicked and then hides it", ->
        @clock = sinon.useFakeTimers()

        showAlertSpy = sinon.spy(TuringEmailApp, "showAlert")
        removeAlertSpy = sinon.spy(TuringEmailApp, "removeAlert")

        @settingsView.saveSettings()

        @server.respondWith "PATCH", @userConfiguration.url, stringifyUserConfiguration(@userConfiguration)
        @server.respond()

        expect(showAlertSpy).toHaveBeenCalled()

        @clock.tick(5000)

        expect(removeAlertSpy).toHaveBeenCalled()

        @clock.restore()
        @server.restore()

        showAlertSpy.restore()
        removeAlertSpy.restore()
