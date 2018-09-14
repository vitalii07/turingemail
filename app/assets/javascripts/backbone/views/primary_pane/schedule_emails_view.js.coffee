TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.ScheduleEmailsView extends TuringEmailApp.Views.CollectionView
  template: JST["backbone/templates/primary_pane/schedule_emails"]

  className: "tm_content tm_content-with-toolbar tm_schedule"

  events:
    "click .new-delayed-email-button": "onNewDelayedEmailClick"
    "click .delete-delayed-email-button": "onDeleteDelayedEmailClick"
    "click .edit-delayed-email-button": "onEditDelayedEmailClick"
    "click .send-delayed-email-button": "onSendDelayedEmailClick"
    "click .period-dropdown .dropdown-menu a": "onPeriodFilterClick"
    "click .email-collapse-expand": "onEmailExpandAndCollapse"
    "click .month-collapse-expand": "onMonthExpandAndCollapse"
    "click .tm_email-schedule-arrow": "onMobileScheduleRowSwipe"
    "click .update-delayed-email-button": "onMobileScheduleUpdate"

  initialize: (options) ->
    super(options)

    @app = options.app
    @periodFilter = -1

  render: ->
    @filteredCollection = if @periodFilter == -1 then @collection else @collection.filterByPeriod(@periodFilter)
    groupedCollection = @filteredCollection.groupByMonth()

    @$el.html @template(
      total: @filteredCollection.length
      weekTotal: @filteredCollection.thisWeek().length
      delayedEmails: groupedCollection
    )

    @$(".tm_email-schedule-dtpicker").each (index, element) =>
      $element = $(element)
      uid = $element.closest(".tm_email-schedule").data("uid")
      email = @collection.get uid

      $element.mobiscroll().datetime
        defaultValue: new Date(email.attributes.send_at)
        dateOrder: 'Mdyy'
        timeWheels: 'hiiA'
        minDate: new Date()
        display: 'inline'
        theme: 'turing'
        rows: 3
        height: 28
        minWidth: 35
        headerText: false
        showLabel: false
        btnWidth: false
        selectedLineHeight: true
        selectedLineBorder: 1
        steps:
          minute: 5
          zeroBased: true
        buttons: [{
          text: '<svg class="icon"><use xlink:href="/images/symbols.svg#mobile-checkmark"></use></svg><span>Save</span>',
          handler: (event, instance) =>
            @updateDatetimeOfDelayedEmail(event, instance)

            instance._markup.parent().removeClass("visible")
        }]

    @


  onPeriodFilterClick: (evt) ->
    @periodFilter = $(evt.currentTarget).data("days")
    @render()
    @$(".period-dropdown-menu").text($(evt.currentTarget).text())

  onNewDelayedEmailClick: (evt) ->
    @app.views.mainView.composeWithSendLaterDatetime()

  onDeleteDelayedEmailClick: (evt) ->
    uid = $(evt.currentTarget).closest(".tm_email").data("uid")
    email = @collection.get uid

    if isMobile()
      email.destroy()
    else
      @app.views.mainView.confirm("Please confirm:").done =>
        email.destroy().then =>
          @app.showAlert("Deleted scheduled email successfully.", "alert-success", 5000)

  onEditDelayedEmailClick: (evt) ->
    uid = $(evt.currentTarget).closest(".tm_email").data("uid")
    delayedEmail = @collection.get uid

    @app.views.mainView.loadEmailDelayed delayedEmail

  onSendDelayedEmailClick: (evt) ->
    uid = $(evt.currentTarget).closest(".tm_email").data("uid")
    delayedEmail = @collection.get uid

    TuringEmailApp.views.mainView.composeView.loadEmailDelayed delayedEmail
    TuringEmailApp.views.mainView.composeView.sendEmail()

  onMonthExpandAndCollapse: (evt) ->
    if $(evt.currentTarget).hasClass("tm_month-collapsed")
      emailMonth = $(evt.currentTarget).removeClass("tm_month-collapsed")
      emailMonth.next().children('.tm_email').removeClass("tm_email-collapsed")
    else
      emailMonth = $(evt.currentTarget).addClass("tm_month-collapsed")
      emailMonth.next().children('.tm_email').addClass("tm_email-collapsed")

  onEmailExpandAndCollapse: (evt) ->
    $(evt.currentTarget).closest(".tm_email").toggleClass("tm_email-collapsed")

  onMobileScheduleRowSwipe: (evt) ->
    currentRow = $(evt.currentTarget).closest(".tm_email-schedule-wrapper").toggleClass("row-swiped")
    $(".tm_email-schedule-wrapper").not(currentRow).removeClass("row-swiped")

  onMobileScheduleUpdate: (evt) ->
    emailRow = $(evt.currentTarget).closest(".tm_email-schedule")
    $(".tm_email-schedule-wrapper", emailRow).removeClass("row-swiped")
    $(".tm_email-schedule-dtpicker", emailRow).addClass("visible")

  updateDatetimeOfDelayedEmail: (event, instance) ->
    #get date
    selectedDateValues = instance.getArrayVal()
    month = parseInt(selectedDateValues[0]) + 1
    selectedDate = if month < 10 then "0" + month + "/" else month + "/"
    selectedDate += if parseInt(selectedDateValues[1]) < 10 then "0" + selectedDateValues[1] + "/" else selectedDateValues[1] + "/"
    selectedDate += selectedDateValues[2] + " " + selectedDateValues[3] + ":"
    selectedDate += if parseInt(selectedDateValues[4]) < 10 then "0" + selectedDateValues[4] else selectedDateValues[4]
    selectedDate += if parseInt(selectedDateValues[5]) == 1 then " pm" else " am"

    #set date
    @onEditDelayedEmailClick(event)
    @app.views.mainView.composeView.sendEmailDelayed selectedDate
