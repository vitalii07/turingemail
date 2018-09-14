class TuringEmailApp.Models.EmailGroup extends TuringEmailApp.Models.BaseModel
  initialize: (attributes, options) ->
    @app  = options.app
    @page = 1


  parse: (response, options) ->
    res = super(response, options)

    res.loaded = true

    for email in (res.emails || [])
      if email.from_address != TuringEmailApp.currentEmailAddress()
        lastEmail = email
        break

    lastEmail = res.emails?[0] unless lastEmail?

    if lastEmail
      res.snippet = lastEmail.snippet

      res.from_name = lastEmail.from_name
      res.from_address = lastEmail.from_address
      res.date = new Date(lastEmail.date)
      res.subject = lastEmail.subject

    folderIDs = []

    res.seen = true
    for email in (res.emails || [])
      email.date = new Date(email.date)

      res.seen = false if !email.seen
      folderIDs = folderIDs.concat(email.folder_ids) if email.folder_ids?

    res.emails?.sort (a, b) -> a.date - b.date

    res.folder_ids = _.uniq(folderIDs)

    res


  numEmails: ->
    @get("emails_count")


  numEmailsText: (numEmails = @numEmails()) ->
    if numEmails == 1 then "" else "(#{numEmails})"


  fromPreview: (fromAddress = @get("from_address"),
                fromName = @get("from_name")) ->
    if fromAddress == TuringEmailApp.currentEmailAddress()
      "me"
    else
      fromName?.trim() || fromAddress


  snippetPreview: (snippet = @get("snippet")) ->
    escapeHTML (snippet?.replace("&#39;", "'") || "")


  subjectPreview: (subject = @get("subject")) ->
    escapeHTML (subject?.replace("&#39;", "'") || "(no subject)")


  datePreview: (date = @get("date")) ->
    TuringEmailApp.Models.Email.localDateString(date)


  hasAttachment: (emails = @get("emails")) ->
    for email in emails
      return true if email.email_attachments?.length > 0
    return false


  primaryEmailFolder: ->
    @get("emails")?[0]?["folder_ids"]?[0]
