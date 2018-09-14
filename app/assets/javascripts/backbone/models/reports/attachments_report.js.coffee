TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.AttachmentsReport extends TuringEmailApp.Models.BaseModel
  url: "/api/v1/email_reports/attachments_report"

  validation:
    average_file_size:
      required: true

    content_type_stats:
      required: true

  getCountsByFileType: ->
    contentTypeStats = @get "content_type_stats"

    counts =
      all: 0
      image: 0
      document: 0
      other: 0

    _.each contentTypeStats, (stat, contentType) ->
      if TuringEmailApp.Mixins.getFileType(contentType) == "image"
        counts.image += stat.num_attachments
      else if TuringEmailApp.Mixins.getFileType(contentType) == "document"
        counts.document += stat.num_attachments
      else
        counts.other += stat.num_attachments

      counts.all += stat.num_attachments

    return counts