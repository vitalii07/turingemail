describe "EmailFoldersCollection", ->
  beforeEach ->
    @emailFoldersCollection = new TuringEmailApp.Collections.EmailFoldersCollection(undefined,
      app: TuringEmailApp
    )

  it "has the right url", ->
    expect(@emailFoldersCollection.url).toEqual("/api/v1/email_folders")
    
  it "should use the EmailFolder model", ->
    expect(@emailFoldersCollection.model).toEqual TuringEmailApp.Models.EmailFolder
