class TuringEmailApp.Routers.EmailRemindersRouter extends TuringEmailApp.Routers.BaseRouter
  routes:
    "email_reminders": "showEmailReminders"

  showEmailReminders: ->
    TuringEmailApp.showEmailReminders()