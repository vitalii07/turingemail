describe "EmailThreadsCollection", ->
  beforeEach ->
    TuringEmailApp.collections = {}
    emailFoldersData = FactoryGirl.createLists("EmailFolder", FactoryGirl.SMALL_LIST_SIZE)
    TuringEmailApp.collections.emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection(emailFoldersData,
      app: TuringEmailApp
    )
    @emailThreadsCollection = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
      app: TuringEmailApp
    )

  it "has the right url", ->
    expect(@emailThreadsCollection.url).toEqual("/api/v1/email_threads/in_folder?folder_id=INBOX")

  it "should use the EmailThread model", ->
    expect(@emailThreadsCollection.model).toEqual(TuringEmailApp.Models.EmailThread)

  describe "#initialize", ->
    beforeEach ->
      @emailThreadsCollectionTemp = new TuringEmailApp.Collections.EmailThreadsCollection(undefined,
        app: TuringEmailApp
        folderID: "INBOX"
      )

    it "initializes the variables", ->
      expect(@emailThreadsCollectionTemp.app).toEqual(TuringEmailApp)
      expect(@emailThreadsCollectionTemp.pageTokenIndex).toEqual(0)
      expect(@emailThreadsCollectionTemp.folderID).toEqual("INBOX")

  describe "Network", ->
    describe "#sync", ->
      beforeEach ->
        @emailThreadsCollection.folderIDIs("INBOX")

        @superStub = sinon.stub(TuringEmailApp.Collections.EmailThreadsCollection.__super__, "sync")
        @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)

        @method = "read"
        @collection = {}
        @options = {}

        @emailThreadsCollection.sync(@method, @collection, @options)

      afterEach ->
        @triggerStub.restore()
        @superStub.restore()

      it "calls super", ->
        expect(@superStub).toHaveBeenCalledWith(@method, @collection, @options)

      it "does not trigger the request event", ->
        expect(@triggerStub).not.toHaveBeenCalled()

      # TO DO: Add specs for the search query case.

  describe "#parse", ->
    beforeEach ->
      @threadsJSON = [[], []]
      @setThreadPropertiesFromJSONStub = sinon.stub(TuringEmailApp.Models.EmailThread, "SetThreadPropertiesFromJSON")

      @emailThreadsCollection.parse(@threadsJSON)

    afterEach ->
      @setThreadPropertiesFromJSONStub.restore()

    it "updates the threadsJSON properties", ->
      expect(@setThreadPropertiesFromJSONStub).toHaveBeenCalledWith(threadJSON) for threadJSON in @threadsJSON

  describe "with models", ->
    beforeEach ->
      @emailThreadsCollection.add(FactoryGirl.createLists("EmailThread", FactoryGirl.SMALL_LIST_SIZE))

    describe "Setters", ->
      describe "#resetPageTokenIndex", ->
        beforeEach ->
          @oldPageTokens = @emailThreadsCollection.pageTokens
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex

          @emailThreadsCollection.resetPageTokenIndex()

        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex
          @emailThreadsCollection.pageTokens = @oldPageTokens

        it "resets the page token index", ->
          expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)

      describe "#folderIDIs", ->
        beforeEach ->
          @resetPageTokenIndexStub = sinon.stub(@emailThreadsCollection, "resetPageTokenIndex", ->)
          @setupURLStub = sinon.stub(@emailThreadsCollection, "setupURL", ->)
          @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)
          @emailThreadsCollection.folderIDIs(@emailThreadsCollection.folderID)

        afterEach ->
          @triggerStub.restore()
          @resetPageTokenIndexStub.restore()

        it "calls setupURL", ->
          expect(@setupURLStub).toHaveBeenCalled()

        describe "folder ID is equal to the current folder ID", ->
          beforeEach ->
            @emailThreadsCollection.folderIDIs(@emailThreadsCollection.folderID)

          it "does reset the page tokens", ->
            expect(@resetPageTokenIndexStub).toHaveBeenCalled()

          it "triggers the change:pageTokenIndex event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:folderID", @emailThreadsCollection, @emailThreadsCollection.folderID)

        describe "folder ID is NOT equal to the current folder ID", ->
          beforeEach ->
            @emailThreadsCollection.folderIDIs("test")

          it "does reset the page tokens", ->
            expect(@resetPageTokenIndexStub).toHaveBeenCalled()

          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:folderID", @emailThreadsCollection, "test")

      describe "pageTokenIndexIs", ->
        beforeEach ->
          @triggerStub = sinon.stub(@emailThreadsCollection, "trigger", ->)
          @emailThreadsCollection.folderID = TuringEmailApp.collections.emailFolders.models[0].get("label_id")

        afterEach ->
          @triggerStub.restore()

        describe "when the page token index is in range", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndexIs(0)

          it "updates the page token index", ->
            expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)

          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:pageTokenIndex", @emailThreadsCollection, 0)

        describe "when the page token index is NOT in range", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndexIs(1)

          it "updates the page token index", ->
            expect(@emailThreadsCollection.pageTokenIndex).toEqual(0)

          it "triggers the change:folderID event", ->
            expect(@triggerStub).toHaveBeenCalledWith("change:pageTokenIndex", @emailThreadsCollection, 0)

      describe "#setupURL", ->
        beforeEach ->
          @emailThreadsCollection.folderID = "test"

        it "set the correct URL", ->
          @emailThreadsCollection.setupURL("1", "ASC")
          expect(@emailThreadsCollection.url).toEqual("/api/v1/email_threads/in_folder?folder_id=test&last_email_thread_uid=1&dir=ASC")

      describe "#emailThreadsSeenIs", ->
        beforeEach ->
          @seenValue = true

          @postStub = sinon.stub($, "post")

          @postData = {}
          @postData.email_uids = _.reduce @emailThreadsCollection.models, ((uids, emailThread) ->
            uids.concat (email.uid for email in emailThread.get("emails"))
          ), []
          @postData.seen = @seenValue

          emailThreadUIDs = (emailThread.get("uid") for emailThread in @emailThreadsCollection.models)
          @emailThreadsCollection.emailThreadsSeenIs(emailThreadUIDs, @seenValue)

        afterEach ->
          @postStub.restore()

        it "posts", ->
          expect(@postStub).toHaveBeenCalledWith("/api/v1/emails/set_seen", @postData)

    describe "Getters", ->
      describe "#hasNextPage", ->
        beforeEach ->
          @oldPageTokens = @emailThreadsCollection.pageTokens
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex

        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex
          @emailThreadsCollection.pageTokens = @oldPageTokens

        describe "has a next page", ->
          beforeEach ->
            @numIndexesInFolderStub = sinon.stub(@emailThreadsCollection, "numIndexesInFolder", -> 5)
            @emailThreadsCollection.reset([])

          afterEach ->
            @numIndexesInFolderStub.restore()

          it "returns true", ->
            expect(@emailThreadsCollection.hasNextPage()).toBeTruthy()

        describe "does NOT have a next page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokens = [null]
            @numIndexesInFolderStub = sinon.stub(@emailThreadsCollection, "numIndexesInFolder", -> 0)

          afterEach ->
            @numIndexesInFolderStub.restore()

          it "returns false", ->
            expect(@emailThreadsCollection.hasNextPage()).toBeFalsy()

      describe "#hasPreviousPage", ->
        beforeEach ->
          @oldPageTokenIndex = @emailThreadsCollection.pageTokenIndex

        afterEach ->
          @emailThreadsCollection.pageTokenIndex = @oldPageTokenIndex

        describe "does NOT have a previous page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndex = 0

          it "returns false", ->
            expect(@emailThreadsCollection.hasPreviousPage()).toBeFalsy()

        describe "has a previous page", ->
          beforeEach ->
            @emailThreadsCollection.pageTokenIndex = 1

          it "returns true", ->
            expect(@emailThreadsCollection.hasPreviousPage()).toBeTruthy()
