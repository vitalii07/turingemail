TuringEmailApp.Mixins ||= {}

_.extend TuringEmailApp.Mixins,
  bytesToHumanReadableFileSize: (bytes) ->
    units = ['B', 'kB', 'MB', 'GB', 'TB', 'PB', 'EB', 'ZB', 'YB']
    thresh = 1024

    i = Math.floor(Math.log(bytes) / Math.log(thresh))
    return (bytes / Math.pow(thresh, i)).toFixed(1) + ' ' + units[i]

  getFileType: (contentType) ->
    contentTypes =
      image: [
        "image/jpeg",
        "image/png",
        "image/gif"
      ]
      document: [
        "application/pdf",
        "application/msword",
        "text/plain"
      ]

    if contentTypes.image.indexOf(contentType) > -1
      type = "image"
    else if contentTypes.document.indexOf(contentType) > -1
      type = "document"
    else
      type = "other"
    
    return type