class TuringEmailApp.Models.EmailConversation extends TuringEmailApp.Models.EmailGroup
  url: ->
    "#{super()}?page=#{@page}"
