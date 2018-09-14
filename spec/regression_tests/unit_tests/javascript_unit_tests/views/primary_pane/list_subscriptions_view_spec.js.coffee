describe "ListSubscriptionsView", ->
  beforeEach ->
    specStartTuringEmailApp()

    @listSubscriptions = new TuringEmailApp.Collections.ListSubscriptionsCollection(FactoryGirl.createLists("ListSubscription", FactoryGirl.SMALL_LIST_SIZE))
    @listSubscriptions.at(1).set("unsubscribed", true)
    @listSubscriptionsView = new TuringEmailApp.Views.PrimaryPane.ListSubscriptionsView(collection: @listSubscriptions)

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@listSubscriptionsView.template).toEqual JST["backbone/templates/primary_pane/list_subscriptions"]

  it "has the right events", ->
    expect(@listSubscriptionsView.events["click .unsubscribe-list-button"]).toEqual "onUnsubscribeListClick"
    expect(@listSubscriptionsView.events["click .resubscribe-list-button"]).toEqual "onResubscribeListClick"

  describe "#render", ->

    describe "when the tab ID is selected", ->
      beforeEach ->
        @selectedTabID = "tab-1"
        $('body').append('<div class="tm_content-tab-pane active" id="' + @selectedTabID + '"></div>')

        @listSubscriptionsView.render()

      afterEach ->
        $("#" + @selectedTabID).remove()

  describe "after render", ->
    beforeEach ->
      @listSubscriptionsView.render()

    describe "#onUnsubscribeListClick", ->
      beforeEach ->
        @event =
          currentTarget: $(@listSubscriptionsView.$el.find(".unsubscribe-list-button")[0])
          preventDefault: ->

        @triggerStub = sinon.stub(@listSubscriptionsView, "trigger", ->)

        @listSubscriptionsView.onUnsubscribeListClick(@event)

      afterEach ->
        @triggerStub.restore()

    describe "#onResubscribeListClick", ->
      beforeEach ->
        @event =
          currentTarget: $(@listSubscriptionsView.$el.find(".resubscribe-list-button")[0])
          preventDefault: ->

        @triggerStub = sinon.stub(@listSubscriptionsView, "trigger", ->)

        @listSubscriptionsView.onResubscribeListClick(@event)

      afterEach ->
        @triggerStub.restore()
