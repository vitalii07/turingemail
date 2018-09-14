TuringEmailApp.Models.InstalledApps ||= {}

class TuringEmailApp.Models.InstalledApps.InstalledApp extends TuringEmailApp.Models.BaseModel
  @CreateFromJSON: (installedAppJSON) ->
    if installedAppJSON.installed_app_subclass_type == "InstalledPanelApp"
      return new TuringEmailApp.Models.InstalledApps.InstalledPanelApp(installedAppJSON)

    return null

  @Uninstall: (appID) ->
    $.ajax
      url: "/api/v1/apps/uninstall/" + appID
      type: "DELETE"
