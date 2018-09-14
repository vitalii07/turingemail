class TuringEmailApp.Models.App extends TuringEmailApp.Models.UidModel
  defaults:
    "app_type": "panel"

  @Install: (appID) ->
    $.post "/api/v1/apps/install/#{appID}#{TuringEmailApp.Mixins.syncUrlQuery("?")}"
