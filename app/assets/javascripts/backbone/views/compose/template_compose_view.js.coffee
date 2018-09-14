class TuringEmailApp.Views.TemplateComposeView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/compose/template_compose"]

  events: -> _.extend {}, super(),
#    "submit .compose-form": "onSubmit"
    "click .save-button": "onSubmit"
    "click .compose-modal-size-toggle": "sizeToggle"
    "click .tm_compose-modal-footer .dropdown-menu li a[data-uid]": "onChangeTemplateCategory"
    "hide.bs.dropdown .tm_category-dropup": "onHideCategoryDropup"

    "click .tm_new-category": "ignoreClickOnNewCategory"
    "click .tm_new-category .start-new-category-button": "startNewCategory"
    "keyup .tm_new-category input.tm_new-category-name": "hitEnterOnNewCategoryName"

  initialize: (options) ->
    super()

    @app = options.app
    @tempEmailTemplate = new TuringEmailApp.Models.EmailTemplate()
    @emailTemplateCategories = options.categories
    @newCategory = null

  data: ->
    _.extend {}, super(),
      "dynamic":
        emailTemplate: @tempEmailTemplate
        emailTemplateCategories: @emailTemplateCategories
        newCategory: @newCategory

  render: ->
    super()

    @postRenderSetup()

    @


  #######################
  ### Setup Functions ###
  #######################

  postRenderSetup: ->
    @setupComposeView()

  setupComposeView: ->
    @$(".compose-template-body").redactor
      focus: true
      minHeight: 300
      maxHeight: 400
      linebreaks: true
      buttons: ['formatting', 'bold', 'italic', 'deleted', 'unorderedlist', 'orderedlist', 'outdent', 'indent', 'image', 'file', 'link', 'alignment', 'horizontalrule', 'html']
      plugins: ['fontfamily', 'fontcolor', 'fontsize']
      pasteCallback: (html) ->
        html.split("<br><br><br>").join "<br><br>"

  #######################
  ### Category Create ###
  #######################

  startNewCategory: ->
    @newCategory = new TuringEmailApp.Models.EmailTemplateCategory name: ""
    @ractive.set newCategory: @newCategory

    @$("input.tm_new-category-name").focus()

  cancelNewCategory: ->
    @newCategory = null
    @ractive.set newCategory: @newCategory

    @$(".redactor-editor").focus()

  finishNewCategory: ->
    newCategoryName = @newCategory.get "name"

    if newCategoryName == ""
      @app.showAlert("Please enter a category title", null, 5000)
    else if @emailTemplateCategories.findWhere(name: newCategoryName)? # Check if name already exists
      @app.showAlert("Category with this name already exists", null, 5000)
    else
      # Create new category
      @newCategory.save null,
        "success": =>
          @app.showAlert("Category has been successfully created!", "alert-success", 3000)
          @emailTemplateCategories.add @newCategory

          # Update category names list
          @extractCategoryNames()
          # Change category selected
          @changeCategory @newCategory.get("uid")
          # Closes the dropup
          @$(".tm_category-dropup").trigger("click.bs.dropdown")


  ######################
  ### Event handlers ###
  ######################

  onHideCategoryDropup: (evt) ->
    @cancelNewCategory()

  ignoreClickOnNewCategory: (evt) ->
    evt.stopPropagation()

  hitEnterOnNewCategoryName: (evt) ->
    if evt.keyCode == 13
      @finishNewCategory()

  onSubmit: (evt) ->
    @saveEmailTemplate()

  sizeToggle: (evt) ->
    @$(".compose-modal-dialog").toggleClass("compose-modal-dialog-large compose-modal-dialog-small")
    $(evt.currentTarget).toggleClass("tm_modal-button-compress tm_modal-button-expand")

  ###############
  ### Getters ###
  ###############

  composeBody: ->
    @$(".tm_compose-body .redactor-editor")

  categoryDropup: ->
    @$(".tm_category-dropup")

  #########################
  ### Display Functions ###
  #########################

  extractCategoryNames: ->
    @categoryNames = [];
    @emailTemplateCategories.each (category) =>
      @categoryNames[category.get('uid')] = category.get('name')

    @ractive.set categoryNames: @categoryNames

  show: ->
    @extractCategoryNames()

    @$(".compose-modal").modal(
      backdrop: 'static'
      keyboard: false
    ).show()
    @syncTimeout = window.setTimeout(=>
      @$(".tm_compose-body .redactor-editor").focus()
      @$('.tm_category-dropup .dropdown-menu').css "left", @$('.tm_category-dropup label').width() + 9
    , 1000)

  hide: ->
    @$(".compose-modal").modal "hide"

  bodyHtml: ->
    return @composeBody().html()

  bodyHtmlIs: (bodyHtml) ->
    @composeBody().html bodyHtml

  bodyText: ->
    return @composeBody().text()

  bodyTextIs: (bodyText) ->
    @composeBody().text bodyText

  resetView: ->
    @removeAlert()
    @bodyHtmlIs ""

    @currentEmailTemplate = null
    @tempEmailTemplate.clear()

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


  #####################################
  ### Load Email Template Functions ###
  #####################################

  loadEmpty: (categoryUID) ->
    @resetView()
    @tempEmailTemplate.set
      "category_uid": categoryUID

  loadEmailTemplate: (emailTemplate) ->
    @resetView()

    @currentEmailTemplate = emailTemplate

    emailTemplateJSON = emailTemplate.toJSON()

    @tempEmailTemplate.set
      "uid": if emailTemplateJSON.uid then emailTemplateJSON.uid else ""
      "name": emailTemplateJSON.name
      "text": emailTemplateJSON.text
      "html": emailTemplateJSON.html
      "category_uid": emailTemplateJSON.category_uid

    @loadEmailTemplateBody(emailTemplateJSON)


  loadEmailTemplateBody: (emailTemplateJSON) ->
    console.log("TemplateComposeView loadEmailTemplateBody!!")

    [body, html] = @parseEmailTemplate(emailTemplateJSON)
    body = $.parseHTML(body) if not html && body != ""

    @bodyHtmlIs(body)

    return body

  parseEmailTemplate: (emailTemplateJSON) ->
    htmlFailed = true
    if emailTemplateJSON.html?
      try
        emailTemplateHTML = $($.parseHTML(emailTemplateJSON.html))

        if emailTemplateHTML.length is 0 || not emailTemplateHTML[0].nodeName.match(/body/i)?
          body = $("<div />")
          body.html(emailTemplateHTML)
        else
          body = emailTemplateHTML

        htmlFailed = false
      catch error
        console.log error
        htmlFailed = true

    if htmlFailed
      bodyText = ""

      text = ""
      if emailTemplateJSON.text?
        text = emailTemplateJSON.text

      if text != ""
        for line in text.split("\n")
          bodyText += "> " + line + "\n"

      body = bodyText

    return [body, !htmlFailed]


  ###########################
  ### Save Email Template ###
  ###########################

  saveEmailTemplate: ->
    @ractive.updateModel()

    # Check if name is empty
    if @tempEmailTemplate.get("name") == ""
      TuringEmailApp.showAlert("Please enter a template name", null, 5000)
      return

    tempEmailTemplateJSON = @tempEmailTemplate.toJSON()
    if @currentEmailTemplate? # Update
      if tempEmailTemplateJSON.name != @currentEmailTemplate.get("name") and @app.collections.emailTemplates.findWhere(name: tempEmailTemplateJSON.name)?
        @app.showAlert("Name already exists!",
          "alert-error",
          3000)
        return

      @currentEmailTemplate.set
        "name": tempEmailTemplateJSON.name
        "text": @bodyText()
        "html": tempEmailTemplateJSON.html
        "category_uid": tempEmailTemplateJSON.category_uid

      @currentEmailTemplate.save null,
        patch: true
        "success": =>
          @showSuccessAlert "Template has been saved."

      @showSuccessAlert "Template has been saved successfully."
    else # Create new email Template
      # Check if name already exists
      if @app.collections.emailTemplates.findWhere(name: @tempEmailTemplate.get("name"))?
        @app.showAlert("Name already exists!",
          "alert-error",
          3000)
        return

      # Create new category
      newEmailTemplate = new TuringEmailApp.Models.EmailTemplate
        "name": tempEmailTemplateJSON.name
        "text": @bodyText()
        "html": tempEmailTemplateJSON.html
        "category_uid": tempEmailTemplateJSON.category_uid

      newEmailTemplate.save null,
        "success": =>
          # Add new template to collection
          @app.collections.emailTemplates.add newEmailTemplate
          @showSuccessAlert "Template has been created successfully."

  onChangeTemplateCategory: (evt) ->
    @changeCategory $(evt.currentTarget).data("uid")

  changeCategory: (categoryUID) ->
    @ractive.set "emailTemplate.category_uid": categoryUID