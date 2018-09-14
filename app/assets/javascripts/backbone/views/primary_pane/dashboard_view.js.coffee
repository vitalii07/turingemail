TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.DashboardView  extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/dashboard"]

  className: "tm_content tm_dashboard-view"

  initialize: (options) ->
    super(options)

    @app = options.app

  data: -> _.extend {}, super(),
    "static":
      emailAccounts: @app.collections.emailAccounts.toJSON()
      name: @app.models.user.get("name")
      userAddress: @app.collections.emailAccounts.current_email_account
      memberSince: moment(@model.get("membership")?["from_date"]).format("MMMM")
      nextBillingDate: moment(@model.get("payment_info")?["next_billing_date"]).format("MMMM Do YYYY")
    "dynamic" :
      paymentInformation: @model
