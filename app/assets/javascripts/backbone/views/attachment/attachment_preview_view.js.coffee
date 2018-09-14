class TuringEmailApp.Views.AttachmentPreviewView extends TuringEmailApp.Views.RactiveView
  @dateFormat: "m/d/Y g:i a"

  template: JST["backbone/templates/attachment/attachment_preview"]


  events: -> _.extend {}, super(),
    "click .compose-modal-size-toggle": "sizeToggle"
    "click .share-attachment-button": "shareEmailAttachment"
    "click .delete-attachment-button": "deleteEmailAttachment"
    "click .download-attachment-button": "downloadEmailAttachment"

  initialize: (options) ->
    super()

    @app = options.app
    @currentEmailAttachment = null


  data: ->
    _.extend {}, super(),
      "dynamic":
        "emailAttachment": @currentEmailAttachment


  render: ->
    super()

    @


  #######################
  ### Setup Functions ###
  #######################

  sizeToggle: (evt) ->
    @$(".compose-modal-dialog").toggleClass("compose-modal-dialog-large compose-modal-dialog-small")
    $(evt.currentTarget).toggleClass("tm_modal-button-compress tm_modal-button-expand")

  #########################
  ### Display Functions ###
  #########################

  show: ->
    @$(".compose-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()
    @$(".modal-dialog").css "max-width", @$(".tm_attachment-image img").width()

  hide: ->
    @$(".compose-modal").modal "hide"

  resetView: ->
    @removeAlert()
    @currentEmailAttachment = null
    @ractive.set "emailAttachment", @currentEmailAttachment


  #######################
  ### Alert Functions ###
  #######################

  showSuccessAlert: (message) ->
    @removeAlert() if @currentAlertToken?

    @currentAlertToken = @app.showAlert message, "alert-success", 3000

    @hide()

  removeAlert: ->
    if @currentAlertToken?
      @app.removeAlert @currentAlertToken
      @currentAlertToken = null


  #################################
  ### Load Attachment Functions ###
  #################################

  loadEmailAttachment: (emailAttachment) ->
    @resetView()
    @currentEmailAttachment = emailAttachment
    @ractive.set "emailAttachment", @currentEmailAttachment


  #################################
  ### Download Email Attachment ###
  #################################

  downloadEmailAttachment: ->
    if @currentEmailAttachment
      TuringEmailApp.Models.EmailAttachment.Download @app, @currentEmailAttachment.get("uid")


  ##############################
  ### Share Email Attachment ###
  ##############################

  shareEmailAttachment: ->
    if @currentEmailAttachment
      @hide()
      TuringEmailApp.views.mainView.composeWithAttachment @currentEmailAttachment


  ###############################
  ### Delete Email Attachment ###
  ###############################

  deleteEmailAttachment: ->
    console.log "delete Email attachment"
    @