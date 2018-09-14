class TuringEmailApp.Models.EmailThreadStats extends TuringEmailApp.Models.UidModel
  urlRoot: "/api/v1/email_threads/stats"

  initialize: ->
    @subjectsData = new TuringEmailApp.Models.EmailThreadSubjectsData

  fetch: ->
    super "success" : =>
      @subjectsData.set "uid" : @id
      @subjectsData.set(@get("recent_thread_subjects"))
