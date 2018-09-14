TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.EmailVolumeReport extends TuringEmailApp.Models.BaseModel
  url: "/api/v1/email_reports/volume_report"

  validation:
    received_emails_per_month:
      required: true

    received_emails_per_week:
      required: true

    received_emails_per_day:
      required: true

    sent_emails_per_month:
      required: true

    sent_emails_per_week:
      required: true

    sent_emails_per_day:
      required: true
