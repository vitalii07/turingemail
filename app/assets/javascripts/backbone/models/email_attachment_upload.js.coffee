class TuringEmailApp.Models.EmailAttachmentUpload extends TuringEmailApp.Models.BaseModel
  @DownloadsInProgress: {}

  # TODO write tests
  @GetUploadAttachmentPost: ->
    url = "/api/v1/users/upload_attachment_post#{TuringEmailApp.Mixins.syncUrlQuery("?")}"

    $.get(url)
