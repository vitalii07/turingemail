class TuringEmailApp.Collections.EmailConversationsCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.EmailConversation
  url: "/api/v1/email_conversations"


  initialize: (attributes, options) ->
    @page = 1


  comparator: (a, b) ->
    b.get("date") - a.get("date")


  fetch: (options) ->
    syncOptions =
      "remove": false
      "url": "#{@url}?page=#{@page}"

    syncOptions.url += "&search_query=#{@search_query}" if @search_query?

    super(_.extend(syncOptions, options))
