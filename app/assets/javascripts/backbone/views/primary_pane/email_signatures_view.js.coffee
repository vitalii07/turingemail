TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailSignaturesView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_signatures"]

  events:
    "click .save-email-signature": "onSaveEmailSignature"
    "click .delete-current-email-signature": "onDeleteCurrentEmailSignature"
    "click .cancel-current-email-signature": "onCancelCurrentEmailSignature"
    "click .tm_signature-preview .edit-email-signature": "onEditEmailSignature"
    "click .tm_signature-preview .delete-email-signature": "onDeleteEmailSignature"
    "change .tm_signature-preview .tm_signature-preview-radio input": "onSaveDefaultSignature"
    "click .create-email-signature": "onCreateEmailSignature"

  className: "tm_content tm_signature-view"

  initialize: (options) ->
    super(options)

    @app = options.app
    @emailSignatures = options.emailSignatures
    @emailSignatureUID = options.emailSignatureUID
    @currentEmailSignature = null
    @mobileShowEditor = false

    @listenTo(options.emailSignatures, "reset", @render)

  data:-> _.extend {}, super(),
    "dynamic":
      emailSignatures: @emailSignatures
      emailSignatureUID: @emailSignatureUID
      currentEmailSignature: @currentEmailSignature

  render: ->
    super()

    @setupSignatureEditor()
    @setupSignatureTitleInput()
    @setupSignatureEditorCustomButtons()
    @setupSignatureEditorEvents()
    @resetView()


  #######################
  ### Setup functions ###
  #######################

  setupSignatureEditor: ->
    @$(".compose-signature").redactor
      focus: true
      minHeight: if isMobile() then 100 else 200
      maxHeight: 400
      linebreaks: true
      buttons: ['formatting', 'bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'file', 'link', 'alignment', 'horizontalrule', 'html']
      plugins: ['fontfamily', 'fontcolor', 'fontsize']

    @editor = @$(".redactor-editor")
    @toolbar = @$(".redactor-toolbar")

  setupSignatureTitleInput: ->
    @title = $("<input type='text' class='tm_signature-title' placeholder='Signature Title'>")
    $titleWrap = $("<div class='tm_signature-title-wrap'>")
    @title.appendTo($titleWrap)
    $titleWrap.insertAfter(@toolbar)

  setupSignatureEditorCustomButtons: ->
    @cancelButton = $("<li class='custom-button'>")
    $cancelButtonLink = $('<a class="re-icon redactor-btn-image cancel-current-email-signature" tabindex="-1"><svg class="icon"><use xlink:href="/images/symbols.svg#modal-close"></use></svg></a>')
    @cancelButton.append $cancelButtonLink
    @toolbar.append @cancelButton

    @deleteButton = $("<li class='custom-button'>")
    $deleteButtonLink = $('<a class="re-icon redactor-btn-image delete-current-email-signature" tabindex="-1"><svg class="icon"><use xlink:href="/images/symbols.svg#delete"></use></svg></a>')
    @deleteButton.append $deleteButtonLink
    @toolbar.append @deleteButton

  setupSignatureEditorEvents: ->
    focusables = @$(".tm_signature-title, .redactor-editor")

    focusables.focus (evt) ->
      $(@).closest(".tm_signature-compose").addClass "focused"

    focusables.blur (evt) ->
      $(@).closest(".tm_signature-compose").removeClass "focused"

    focusables.on "input", (evt) =>
      if @currentEmailSignature
        @editingStarted = true

        @ractive.set
          editingStarted: @editingStarted


  ######################
  ### Event handlers ###
  ######################

  onSaveEmailSignature: ->
    if @currentEmailSignature
      emailSignature = @currentEmailSignature
      message = "You have successfully updated an email signature!"
    else
      emailSignature = new TuringEmailApp.Models.EmailSignature()
      message = "You have successfully saved an email signature!";

    title = @signatureTitle()
    # Check if title is empty
    if title == ""
      TuringEmailApp.showAlert("Please fill out the title field!",
        "alert-error",
        3000)
      return
    text = @signatureText()
    html = @signatureHtml()

    emailSignature.set({
      name: title,
      text: text,
      html: html
    })
    emailSignature.save(null, {
      patch: true
      success: (model, response) =>
        TuringEmailApp.showAlert(message, "alert-success", 5000)
        @emailSignatures.fetch(reset: true)
    })

  onCancelCurrentEmailSignature: (evt) ->
    @resetView()

  onDeleteCurrentEmailSignature: (evt) ->
    emailSignature = @currentEmailSignature
    @deleteEmailSignature(emailSignature, true)

  onEditEmailSignature: (evt) ->
    uid = $(evt.currentTarget).closest('.tm_signature-preview').data "uid"
    emailSignature = @emailSignatures.get uid
    @loadEmailSignature emailSignature

  onDeleteEmailSignature: (evt) ->
    uid = $(evt.currentTarget).closest('.tm_signature-preview').data "uid"
    emailSignature = @emailSignatures.get uid
    @deleteEmailSignature(emailSignature)

  onSaveDefaultSignature: (evt) ->
    uid = @ractive.get("emailSignatureUID")

    @app.models.userConfiguration.set({
      email_signature_uid: uid
    })

    @app.models.userConfiguration.save(null, {
        patch: true
        success: (model, response) ->
          TuringEmailApp.showAlert("You have successfully saved your settings!", "alert-success", 5000)
      }
    )

  onCreateEmailSignature: (evt) ->
    @mobileShowEditor = true

    @ractive.set
      mobileShowEditor: @mobileShowEditor

    @$(".tm_signature-title").focus()


  ###########################
  ### Getters and setters ###
  ###########################

  signatureHtml: ->
    return @editor.html()

  signatureHtmlIs: (signatureHtml) ->
    @editor.html signatureHtml

  signatureText: ->
    return @editor.text()

  signatureTextIs: (signatureText) ->
    @editor.text signatureText

  signatureTitle: ->
    return @title.val()

  signatureTitleIs: (signatureTitle) ->
    @title.val signatureTitle


  #########################
  ### Utility functions ###
  #########################

  resetView: ->
    @currentEmailSignature = null
    @editingStarted = false
    @mobileShowEditor = false
    @deleteButton.hide()

    @ractive.set
      currentEmailSignature: @currentEmailSignature
      editingStarted: @editingStarted
      mobileShowEditor: @mobileShowEditor

    @signatureHtmlIs ""
    @signatureTitleIs ""

  loadEmailSignature: (emailSignature) ->
    @resetView()

    @currentEmailSignature = emailSignature
    @deleteButton.show()

    @ractive.set
      currentEmailSignature: @currentEmailSignature

    @signatureHtmlIs emailSignature.get("html")
    @signatureTitleIs emailSignature.get("name")

  deleteEmailSignature: (emailSignature, resetView = false) ->
    if isMobile()
      @deleteEmailSignatureAction(emailSignature, resetView)
    else
      @app.views.mainView.confirm("Please confirm:").done =>
        @deleteEmailSignatureAction(emailSignature, resetView)

  deleteEmailSignatureAction: (emailSignature, resetView = false) ->
    if emailSignature.get("uid") is @emailSignatureUID
      @trigger("currentEmailSignatureDeleted", this)

    emailSignature.destroy().then =>
      @app.showAlert("You have successfully deleted an email signature!",
        "alert-success", 5000
      )

      @emailSignatures.remove(emailSignature)

      if resetView
        @resetView()