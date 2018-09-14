TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailThreads ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailThreads.ContextSidebarView extends TuringEmailApp.Views.RactiveView
  className: "tm_mail-context-sidebar"
  template: JST["backbone/templates/primary_pane/email_threads/context_sidebar"]

  events: -> _.extend {}, super(),
    "click [data-send-to-current]"  : "sendToCurrent"
    "click #load-activities"        : "loadActivities"
    "click #follow-twitter-account" : "followTwitterAccount"

  data: -> _.extend {}, super(),
    "static"  : _.extend({"from_name": "", "from_address": ""}, @model.toJSON())
    "dynamic" :
      "person"                  : @person
      "emailThreadStats"        : @emailThreadStats
      "emailThreadSubjects"     : @emailThreadStats.subjectsData.subjects
      "emailThreadSubjectsData" : @emailThreadStats.subjectsData
      "twitterFriendship"       : @twitterFriendship
      "twitterTimeline"         : @twitterTimeline
      "datePreview"             : TuringEmailApp.Models.Email.localDateString

  initialize: (options)->
    super(options)

    @person            = new TuringEmailApp.Models.Person
    @emailThreadStats  = new TuringEmailApp.Models.EmailThreadStats
    @twitterFriendship = new TuringEmailApp.Models.TwitterFriendship
    @twitterTimeline   = new TuringEmailApp.Models.TwitterTimeline
    @emailThreadView  = options.emailThreadView

  render: ->
    super()

    if @model.id
      @emailThreadStats.set "uid" : @model.id
      @emailThreadStats.fetch()

    if @model.get("from_address")
      @person.set(
        @person.parse(
          _.findWhere(
            @model.get("people"),
            "email_address" : @model.get("from_address")
          )
        )
      )
      twitterScreenName =
        _.findWhere(@person.get("fullcontact_data")?["socialProfiles"],
                    "type" : "twitter")?["username"]

      if twitterScreenName
        @twitterFriendship.unset "is_following"
        @twitterFriendship.set   "screen_name" : twitterScreenName
        @twitterFriendship.fetch()

        @twitterTimeline.unset   "tweets"
        @twitterTimeline.set     "screen_name" : twitterScreenName
        @twitterTimeline.fetch()

    @

  followTwitterAccount: ->
    @twitterFriendship.save()

  sendToCurrent: ->
    address = @model.get "from_address"
    @emailThreadView.trigger("sendClicked", address) if address

  loadActivities: ->
    @emailThreadStats.subjectsData.fetch()
