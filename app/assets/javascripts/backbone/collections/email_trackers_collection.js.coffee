class TuringEmailApp.Collections.EmailTrackersCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.EmailTracker
  url: "/api/v1/email_trackers"

  sortField: "sent"
  comparators:
    "sent": (model) ->
      -new Date(model.get("email_date")).getTime()
    "subject": (model) ->
      model.get("email_subject")

  sortByField: (field) ->
    @sortField = field

    if field == "sent"
      @comparator = @comparators["sent"]
    else if field == "subject"
      @comparator = @comparators["subject"]
    else
      @comparator = @comparators["sent"]

    @sort()

  filterBy: (keyword) ->
    if not keyword
      return @

    keyword = keyword.toLowerCase()
    new TuringEmailApp.Collections.EmailTrackersCollection @filter((emailTracker) ->
      result = false

      if emailTracker.get("email_subject").toLowerCase().indexOf(keyword) > -1 # check against subject
        result = true
      else #check against recipients' email
        recipients = emailTracker.get("email_tracker_recipients")
        filteredRecipients = _.filter(recipients, (recipient) ->
          return recipient.email_address.indexOf(keyword) > -1
        )
        result = filteredRecipients.length > 0

      return result
    )