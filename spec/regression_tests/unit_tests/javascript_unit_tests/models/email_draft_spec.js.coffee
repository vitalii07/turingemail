describe "EmailDraft", ->
  beforeEach ->
    @emailDraft = new TuringEmailApp.Models.EmailDraft()
    @draftID = "id"
    @emailDraft.set("draft_id", @draftID)

  describe "Class Functions", ->

  it "has the right url", ->
    expect(@emailDraft.url).toEqual("/api/v1/email_accounts/drafts")

  describe "#sendDraft", ->
    beforeEach ->
      @sendDraftStub = sinon.stub(TuringEmailApp.Models.EmailDraft, "sendDraft")
      @success = sinon.stub()
      @error = sinon.stub()

      @emailDraft.sendDraft(TuringEmailApp, @success, @error)

    afterEach ->
      @sendDraftStub.restore()

    # it "sends the draft", ->
    #   expect(@sendDraftStub).toHaveBeenCalledWith(TuringEmailApp, @draftID, @success, @error)