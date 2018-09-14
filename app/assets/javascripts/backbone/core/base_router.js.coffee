class TuringEmailApp.Routers.BaseRouter extends Backbone.Router
  execute: (callback, args, name) ->
    route = window.location.hash

    @executeRouteHighlighting(route)

    @executeResetSearchQuery(route)

    super(callback, args)

  executeRouteHighlighting: (route) ->
    topAndSidbarRoutes = ["#conversations", "#email_folder/INBOX"]

    if route in topAndSidbarRoutes
      # Update top bar
      $('.tm_toptabs a.active').removeClass("active")
      $('.tm_toptabs a[href="' + route + '"]').addClass("active")

      # Update side bar
      $('.tm_folders a.tm_folder-selected').removeClass("tm_folder-selected")
      $('.tm_folders a[href="' + route + '"]').addClass("tm_folder-selected")

  executeResetSearchQuery: (route) ->
    excludedRoutesRegex = /^#(search|email_folder|email_thread)/gi

    TuringEmailApp.resetSearchQuery() if not route.match excludedRoutesRegex