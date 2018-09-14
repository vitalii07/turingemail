TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.ImpactReport extends TuringEmailApp.Models.BaseModel
  url: "/api/v1/email_reports/impact_report"

  validation:
    percent_sent_emails_replied_to:
      required: true
