class TuringEmailApp.Routers.ContactInboxRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "conversations": "showContactInbox"

  showContactInbox: ->
    TuringEmailApp.showContactInbox()