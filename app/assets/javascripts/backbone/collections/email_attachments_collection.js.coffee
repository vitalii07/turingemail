class TuringEmailApp.Collections.EmailAttachmentsCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.EmailAttachment

  initialize: (attributes, options) ->
    @dir = "DESC"
    @order_by = "name"
    @type = ""
    @page = 1

  url: ->
    "/api/v1/email_attachments?dir=#{@dir}&order_by=#{@order_by}&type=#{@type}&page=#{@page}"

  filterByType: (type = "") ->
    if not type
      return @

    new TuringEmailApp.Collections.EmailAttachmentsCollection @filter((attachment) ->
      return TuringEmailApp.Mixins.getFileType(attachment.get("content_type")) == type
    )