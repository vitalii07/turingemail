TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.RecommendedRulesReport extends TuringEmailApp.Models.BaseModel
  url: "/api/v1/email_filters/recommended_filters"

  validation:
    rules_recommended:
      required: true
