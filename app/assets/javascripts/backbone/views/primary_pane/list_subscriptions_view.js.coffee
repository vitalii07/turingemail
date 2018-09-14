TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.ListSubscriptionsView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/list_subscriptions"]

  events:
    "click .unsubscribe-list-button": "onUnsubscribeListClick"
    "click .resubscribe-list-button": "onResubscribeListClick"

  className: "tm_content tm_subscriptions-view"

  initialize: (options) ->
    super(options)

    @listsSubscribed = options.listsSubscribed
    @listsUnsubscribed = options.listsUnsubscribed
    @infiniteScrollTriggerable = true

  data: -> _.extend {}, super(),
    "dynamic":
      listsSubscribed: @listsSubscribed
      listsUnsubscribed: @listsUnsubscribed

  render: ->
    super()

    @loadingIndicator = $(".tm_mail-subscriptions-loading").hide()
    @setupInfiniteScroll @$("#tab-subscribed .subscriptions-list-view"), @listsSubscribed
    @setupInfiniteScroll @$("#tab-unsubscribed .subscriptions-list-view"), @listsUnsubscribed

    @setupCheckbox()
    $(".mobile-toolbar-subscriptions").show().siblings().hide()

    @

  onUnsubscribeListClick: (evt) ->
    uid = $(evt.currentTarget).closest("[data-uid]").data("uid")
    listSubscription = @listsSubscribed.get uid

    TuringEmailApp.Models.ListSubscription.Unsubscribe(listSubscription)

    @listsSubscribed.remove(listSubscription)
    listSubscription.set("unsubscribed", true)
    @listsUnsubscribed.add(listSubscription)
    TuringEmailApp.showAlert("Unsubscribed.", "alert-success", 5000)

  onResubscribeListClick: (evt) ->
    uid = $(evt.currentTarget).closest("[data-uid]").data("uid")
    listSubscription = @listsUnsubscribed.get uid

    TuringEmailApp.Models.ListSubscription.Resubscribe(listSubscription)

    @listsUnsubscribed.remove(listSubscription)
    listSubscription.set("unsubscribed", false)
    @listsSubscribed.add(listSubscription)
    TuringEmailApp.showAlert("Resubscribed.", "alert-success", 5000)

  setupInfiniteScroll: (listViewDiv, list) ->
    listViewDiv.scroll =>
      if @infiniteScrollTriggerable
        if listViewDiv.scrollTop() + listViewDiv.height() > listViewDiv.get(0).scrollHeight - 50
          if list.hasNextPage
            @infiniteScrollTriggerable = false
            @loadingIndicator.show()
            # Load more attachments
            list.loadNextPage().then =>
              @infiniteScrollTriggerable = true
              @loadingIndicator.hide()

  setupCheckbox: ->
    @$("div.icheckbox ins").off("click")

    @$(".i-checks").iCheck
      checkboxClass: "icheckbox"
      radioClass: "iradio"
