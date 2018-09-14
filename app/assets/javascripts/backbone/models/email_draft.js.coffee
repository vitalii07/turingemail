class TuringEmailApp.Models.EmailDraft extends TuringEmailApp.Models.Email
  url: "/api/v1/email_accounts/drafts"

  sendDraft: (app, success, error) ->
    postData =
      draft_id: @get("draft_id")

    $.post("/api/v1/email_accounts/send_draft#{@syncUrlQuery("?")}", postData).done(-> success?()).fail(-> error?())
