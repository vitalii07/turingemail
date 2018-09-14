class TuringEmailApp.Models.TwitterFriendship extends TuringEmailApp.Models.BaseModel
  idAttribute: "screen_name"
  urlRoot: "/api/v1/twitter_friendships"


  isNew: ->
    super() || (@get("is_following") == false)
