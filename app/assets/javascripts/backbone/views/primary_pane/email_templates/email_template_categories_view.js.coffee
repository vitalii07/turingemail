TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailTemplates ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplateCategoriesView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_templates/email_template_categories"]
  className: "tm_content tm_content-with-toolbar"

  events:
    "click .tm_content-toolbar .start-create-email-template-category-button": "startCreateEmailTemplateCategory"
    "click .tm_content-toolbar .create-email-template-button": "showCreateUncategorizedEmailTemplateDialog"

    "click .tm_template-new-category .finish-create-email-template-category-button": "finishCreateEmailTemplateCategory"
    "click .tm_template-new-category .cancel-create-email-template-category-button": "cancelCreateEmailTemplateCategory"
    "click .tm_template-category .start-edit-email-template-category-button": "startEditEmailTemplateCategory"
    "click .tm_template-category .finish-edit-email-template-category-button": "finishEditEmailTemplateCategory"
    "click .tm_template-category .cancel-edit-email-template-category-button": "cancelEditEmailTemplateCategory"
    "click .tm_template-category .delete-email-template-category-button": "deleteEmailTemplateCategory"

    "keyup .tm_template-category.tm_template-new-category input.tm_template-category-title": "hitCreateEnter"
    "keyup .tm_template-category:not(.tm_template-new-category) input.tm_template-category-title": "hitEditEnter"

    "click .tm_template-category span.tm_template-category-title": "goToEmailTemplateCategoryPage"
    "click .tm_template-category .create-email-template-button": "showCreateCategorizedEmailTemplateDialog"

  initialize: (options) ->
    super(options)

    @app = options.app
    @templatesCollection = options.templatesCollection
    @tempCategory = null
    @categoryInEdit = null
    @categoryNameInEdit = ""

  data: -> _.extend {}, super(),
    "dynamic":
      "emailTemplateCategories": @collection
      "emailTemplates": @templatesCollection
      "tempCategory": @tempCategory
      "categoryInEdit": @categoryInEdit
      "emailTemplatesCountOfCategory": (categoryUID) ->
        emailTemplates = @get "emailTemplates"

        emailTemplates.filter((emailTemplate) ->
          emailTemplate.get("category_uid") == categoryUID
        ).length

  render: ->
    super()

    @


  setupDialog: (selector, options) ->
    dialogOptions =
      "autoOpen": false
      "width": 400
      "modal": true
      "resizable": false
      "open": ->
        $(selector).keypress (e) ->
          if e.keyCode == $.ui.keyCode.ENTER
            $(@).parent().find(".ui-dialog-buttonpane button:last-child").trigger("click")

    @$(selector).dialog(_.extend(dialogOptions, options))

  #######################
  ### Create Category ###
  #######################

  startCreateEmailTemplateCategory: ->
    @resetView()

    @tempCategory = new TuringEmailApp.Models.EmailTemplateCategory
      name: ""

    @ractive.set
      tempCategory: @tempCategory

    @$(".tm_template-new-category .tm_template-category-title").focus()

  finishCreateEmailTemplateCategory: ->
    newName = @tempCategory.get "name"

    # Check if name is empty
    if newName == ""
      @app.showAlert("Please enter a category title", null, 5000)
      @$(".tm_template-new-category .tm_template-category-title").focus()
      return

    # Check if name already exists
    if @collection.findWhere({name: newName})?
      @app.showAlert("Category with this name already exists", null, 5000)
      @$(".tm_template-new-category .tm_template-category-title").focus()
      return

    # Create new category
    newCategory = @tempCategory.clone()
    newCategory.save null,
      "success": =>
        @cancelCreateEmailTemplateCategory()
        @collection.add newCategory
        @app.showAlert("Category has been successfully created!", "alert-success", 3000)

  cancelCreateEmailTemplateCategory: ->
    @tempCategory = null

    @ractive.set
      tempCategory: @tempCategory


  #######################
  ### Update Category ###
  #######################

  startEditEmailTemplateCategory: (evt) ->
    @resetView()

    $li = $(evt.currentTarget).closest("li")
    uid = $li.data("uid")

    @categoryInEdit = @collection.get(uid).clone()
    @ractive.set "categoryInEdit": @categoryInEdit

    $li.find("input.tm_template-category-title").focus()


  finishEditEmailTemplateCategory: (evt) ->
    uid = $(evt.currentTarget).closest("li").data("uid")
    currentCategory = @collection.get uid

    newName = @categoryInEdit.get "name"
    if newName == ""
      @app.showAlert("Please enter new category title", null, 3000)
      return

    if newName == currentCategory.get("name")
      @cancelEditEmailTemplateCategory()
      return

    # Check if title already exists
    if @collection.where(name: newName).length > 0
      @app.showAlert("Category with this title already exists", null, 3000)
      return

    currentCategory.set "name": newName
    currentCategory.save null,
      patch: true
      success: (model, response) =>
        @app.showAlert("Category has been successfully updated!", "alert-success", 3000)
        @cancelEditEmailTemplateCategory()

  cancelEditEmailTemplateCategory: ->
    @categoryInEdit = null
    @ractive.set categoryInEdit: @categoryInEdit

  #######################
  ### Delete Category ###
  #######################

  deleteEmailTemplateCategory: (evt) ->
    evt.preventDefault()
    @app.views.mainView.confirm("Please confirm:").done =>
      uid = $(evt.currentTarget).closest('[data-uid]').data("uid")
      emailTemplateCategory = @collection.get(uid)

      emailTemplateCategory.destroy().then =>
        @app.showAlert("Category has been successfully deleted!", "alert-success", 3000)

  #############################
  ### Create Email template ###
  #############################

  showCreateUncategorizedEmailTemplateDialog: (evt) ->
    @app.views.mainView.templateComposeView.loadEmpty()
    @app.views.mainView.templateComposeView.show()

  showCreateCategorizedEmailTemplateDialog: (evt) ->
    @resetView()
    categoryUID = $(evt.currentTarget).closest('[data-uid]').data("uid")

    @app.views.mainView.templateComposeView.loadEmpty categoryUID
    @app.views.mainView.templateComposeView.show()

  ##########################################
  ### Go to email template category page ###
  ##########################################

  goToEmailTemplateCategoryPage: (evt) ->
    @resetView()

  #############
  ### Reset ###
  #############

  resetView: ->
    @cancelCreateEmailTemplateCategory()
    @cancelEditEmailTemplateCategory()

  #################
  ### Hit Enter ###
  #################

  hitCreateEnter: (evt) ->
    if evt.keyCode == 13
      @finishCreateEmailTemplateCategory()

  hitEditEnter: (evt) ->
    if evt.keyCode == 13
      @finishEditEmailTemplateCategory(evt)
