describe "InboxCleanerRulesCollection", ->
  beforeEach ->
    @url = "/api/v1/inbox_cleaner_rules"
    @inboxCleanerRulesCollection = new TuringEmailApp.Collections.Rules.InboxCleanerRulesCollection()

  it "should use the InboxCleanerRule model", ->
    expect(@inboxCleanerRulesCollection.model).toEqual TuringEmailApp.Models.Rules.InboxCleanerRule

  it "has the right url", ->
    expect(@inboxCleanerRulesCollection.url).toEqual @url
