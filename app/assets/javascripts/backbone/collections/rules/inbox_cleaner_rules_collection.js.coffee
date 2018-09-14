TuringEmailApp.Collections.Rules ||= {}

class TuringEmailApp.Collections.Rules.InboxCleanerRulesCollection extends TuringEmailApp.Collections.BaseCollection
  model: TuringEmailApp.Models.Rules.InboxCleanerRule
  url: "/api/v1/inbox_cleaner_rules"
