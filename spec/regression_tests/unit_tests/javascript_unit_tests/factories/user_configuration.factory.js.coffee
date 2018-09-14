FactoryGirl.define "UserConfiguration", ->
  @sequence("id", "id")
  @keyboard_shortcuts_enabled = true
  @automatic_inbox_cleaner_enabled = true
  @split_pane_mode = "horizontal"
  @auto_cleaner_enabled = false
  @developer_enabled = false
  @inbox_tabs_enabled = false

  @installed_apps = FactoryGirl.createLists("InstalledPanelApp", FactoryGirl.SMALL_LIST_SIZE)
