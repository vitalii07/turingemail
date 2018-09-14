class TuringEmailApp.Models.ListSubscription extends TuringEmailApp.Models.UidModel
  @Unsubscribe: (listSubscription) ->
    $.ajax
      url: "/api/v1/list_subscriptions/unsubscribe"
      type: "DELETE"
      data: listSubscription.toJSON()

  @Resubscribe: (listSubscription) ->
    $.post("/api/v1/list_subscriptions/resubscribe#{TuringEmailApp.Mixins.syncUrlQuery("?")}", listSubscription.toJSON())
