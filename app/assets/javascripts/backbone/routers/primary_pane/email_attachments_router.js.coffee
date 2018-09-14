class TuringEmailApp.Routers.EmailAttachmentsRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "email_attachments": "showEmailAttachments"

  showEmailAttachments: ->
    TuringEmailApp.showEmailAttachments()
