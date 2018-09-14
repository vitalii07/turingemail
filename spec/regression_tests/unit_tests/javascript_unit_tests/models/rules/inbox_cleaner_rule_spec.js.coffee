describe "InboxCleanerRule", ->

  beforeEach ->
    @inboxCleanerRule = new TuringEmailApp.Models.Rules.InboxCleanerRule()

  it "uses uid as idAttribute", ->
    expect(@inboxCleanerRule.idAttribute).toEqual("uid")
