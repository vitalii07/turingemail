class TuringEmailApp.Models.EmailThreadSubjectsData extends TuringEmailApp.Models.UidModel
  urlRoot: "/api/v1/email_threads/subjects"

  url: ->
    super() + "?page_token=" + @get("next_page_token")

  initialize: ->
    @subjects = new Backbone.Collection

  set: (attrs) ->
    super(attrs)
    @subjects?.set(@get("thread_subjects"), {"remove": false})
