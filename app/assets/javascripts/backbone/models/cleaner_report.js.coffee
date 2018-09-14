class TuringEmailApp.Models.CleanerReport extends TuringEmailApp.Models.BaseModel
  url: "/api/v1/email_accounts/cleaner_report"


  isNew: ->
    !@isFinished()


  isFinished: ->
    @get("progress") == 100
