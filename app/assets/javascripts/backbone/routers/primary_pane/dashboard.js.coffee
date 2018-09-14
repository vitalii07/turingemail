class TuringEmailApp.Routers.DashboardRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "dashboard": "showDashboard"

  showDashboard: ->
    TuringEmailApp.showDashboard()
