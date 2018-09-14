class TuringEmailApp.Collections.ListSubscriptionsCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.ListSubscription

  initialize: (models, options) ->
    super(models, options)

    @page = if options?.page? then options.page else 1
    @unsubscribed = if options?.unsubscribed? then options.unsubscribed else false
    @pageSize = 25
    @hasNextPage = true

  url: ->
    "/api/v1/list_subscriptions?unsubscribed=#{@unsubscribed}&page=#{@page}"

  comparator: (listSubscription) ->
    listSubscription.get "list_name"


  loadNextPage: ->
    console.log "loadNextPage"
    deferred = $.Deferred()

    if @hasNextPage
      @page += 1
      @fetch
        remove: false
        success: (collection, response, options) =>
          @hasNextPage = response.length == @pageSize
          deferred.resolve()
    else
      deferred.resolve()

    return deferred