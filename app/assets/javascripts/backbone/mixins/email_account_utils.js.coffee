TuringEmailApp.Mixins ||= {}


TuringEmailApp.Mixins.EmailAccountUtils =
  syncUrlQuery: (delimiter = "") ->
    emailAccountId = @emailAccountId || window.currentEmailAccountId
    if emailAccountId
      "#{delimiter}email_account_id=#{emailAccountId}"
    else
      ""


  syncUrl: (model, options) ->
    res  = options?["url"] || _.result(model, "url") || _.result(@, "url")

    if @syncUrlQuery()
      res += if res.indexOf("?") == -1 then "?" else "&"
      res += @syncUrlQuery()

    res

_.extend TuringEmailApp.Mixins, TuringEmailApp.Mixins.EmailAccountUtils
