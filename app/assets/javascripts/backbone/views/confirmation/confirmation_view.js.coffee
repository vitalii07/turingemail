class TuringEmailApp.Views.ConfirmationView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/confirmation/confirmation"]

  events: -> _.extend {}, super(),
    "click .yes-button": "onYes"
    "click .no-button": "onNo"

  initialize: (options) ->
    super(options)

    @app = options.app

  data: ->
    _.extend {}, super(),
      "dynamic":
        message: ""

  render: ->
    super()

    @

  onYes: (evt) ->
    @hide()
    @deferred.resolve()

  onNo: (evt) ->
    @hide()
    @deferred.reject()

  #########################
  ### Display Functions ###
  #########################

  show: (message) ->
    @ractive.set
      "message": message

    @deferred = $.Deferred()
    @$(".confirmation-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()

    @deferred

  hide: ->
    @$(".confirmation-modal").modal "hide"
