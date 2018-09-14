class TuringEmailApp.Views.FiltersComposeView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/compose/filters_compose"]


  events: -> _.extend {}, super(),
    "click .save-button"        : "onSubmit"
    "click .dropdown-menu li a" : "onChangeDropdown"


  data: -> _.extend {}, super(),
    "dynamic"  :
      "user"                         : TuringEmailApp.models.user
      "emailFolders"                 : @emailFolders
    "computed" :
      "emailFilter._email_addresses" : TuringEmailApp.Mixins.arrayInputConverter
      "emailFilter._words"           : TuringEmailApp.Mixins.arrayInputConverter


  initialize: (options) ->
    super options

    @app = options.app

    @emailFolders = new TuringEmailApp.Collections.EmailFoldersCollection


  onSubmit: ->
    message =
      if @model.isNew()
        "Filter has been successfully created!"
      else
        "Filter has been successfully updated!"

    @model.save null,
      "wait"    : true
      "success" : => @showSuccessAlert(message)


  show: ->
    @listenTo @model, "change:email_account_id", =>
      @emailFolders.emailAccountId = @model.get("email_account_id")
      @emailFolders.fetch()

    @$(".compose-modal").modal(
      backdrop: "static"
      keyboard: false
    ).show()

    @syncTimeout = window.setTimeout(=>
      @$(".tm_category-dropup .dropdown-menu").css "left", @$(".tm_category-dropup label").width() + 9
    , 1000)


  hide: ->
    @$(".compose-modal").modal "hide"


  showSuccessAlert: (message) ->
    @removeAlert()

    @currentAlertToken = @app.showAlert message, "alert-success", 3000

    @hide()


  removeAlert: ->
    if @currentAlertToken?
      @app.removeAlert @currentAlertToken
      @currentAlertToken = null


  onChangeDropdown: (evt) ->
    $a   = @$(evt.currentTarget)
    $div = $a.parents(".tm_dropdown")

    attr = $a.attr("data-attr")

    $div.find("input[name=\"#{attr}_id\"]").val($a.attr("data-id"))
    $div.find("input[name=\"#{attr}_type\"]").val($a.attr("data-type"))

    @ractive.updateModel()
    @ractive.set "emailFilter.#{attr}" : $a.text()
