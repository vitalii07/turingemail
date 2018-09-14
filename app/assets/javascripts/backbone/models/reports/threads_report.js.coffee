TuringEmailApp.Models.Reports ||= {}

class TuringEmailApp.Models.Reports.ThreadsReport extends TuringEmailApp.Models.BaseModel
  url: "/api/v1/email_reports/threads_report"

  validation:
    average_thread_length:
      required: true

    top_email_threads:
      required: true
