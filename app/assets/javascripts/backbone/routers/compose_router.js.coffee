class TuringEmailApp.Routers.ComposeRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "compose": "navigateToComposeEmail"
    "compose_email": "showCompose"

  navigateToComposeEmail: ->
    @navigate("#compose_email", trigger: true)

  showCompose: ->
    TuringEmailApp.showCompose()
