TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.GeoReport extends TuringEmailApp.Models.BaseModel
  url: "/api/v1/email_reports/ip_stats_report"

  validation:
    ip_stats:
      required: true
