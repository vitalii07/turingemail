class TuringEmailApp.Routers.FiltersRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "filters": "showFilters"

  showFilters: ->
    TuringEmailApp.showFilters()
