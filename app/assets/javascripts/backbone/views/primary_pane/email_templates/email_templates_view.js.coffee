TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.EmailTemplates ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplatesView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_templates/email_templates"]
  className: "tm_content tm_content-with-toolbar"

  events:
    "click .create-email-template-button": "showCreateEmailTemplateDialog"
    "click .edit-email-template-button": "showEditEmailTemplateDialog"
    "click .move-email-template-button": "showMoveEmailTemplateDialog"
    "click .delete-email-template-button": "onDeleteEmailTemplateClick"
    "click .start-edit-template-category-title": "startEditTemplateCategoryTitle"
    "click .finish-edit-template-category-title": "finishEditTemplateCategoryTitle"
    "click .cancel-edit-template-category-title": "cancelEditTemplateCategoryTitle"
    "keyup input.tm_template-toolbar-title": "hitEnter"

  initialize: (options) ->
    super(options)

    @app = options.app
    @categoriesCollection = @app.collections.emailTemplateCategories
    @categoryUID = options.categoryUID
    @category = if @categoryUID then @app.collections.emailTemplateCategories.get(@categoryUID) else null
    @categoryNameInEdit = ""

    @listenTo @app.collections.emailTemplates, 'add', @render
    @listenTo @app.collections.emailTemplates, 'change', @render
    @listenTo @app.collections.emailTemplates, 'destroy', @render

  data: -> _.extend {}, super(),
    "dynamic":
      "emailTemplates": @collection
      "categories": @categoriesCollection
      "category": @category
      "categoryNameInEdit": @categoryNameInEdit

  render: ->
    @collection = if not @categoryUID then @app.collections.emailTemplates else
      @app.collections.emailTemplates.filter((emailTemplate) =>
        emailTemplate.get("category_uid") == @categoryUID
      )

    super()

    @setupEmailExpandAndCollapse()
    @setupMoveEmailTemplateDialog()

    @

  setupDialog: (selector, options) ->
    dialogOptions =
      "autoOpen": false
      "width": 400
      "modal": true
      "resizable": false

    @$(selector).dialog(_.extend(dialogOptions, options))

  setupEmailExpandAndCollapse: ->
    @$(".template-collapse-expand").click (evt) ->
      template = $(evt.currentTarget).closest(".tm_template")
      template.toggleClass("tm_template-collapsed")

  ##############
  ### Create ###
  ##############

  showCreateEmailTemplateDialog: ->
    @app.views.mainView.templateComposeView.loadEmpty @categoryUID
    @app.views.mainView.templateComposeView.show()

  ############
  ### Edit ###
  ############

  showEditEmailTemplateDialog: (evt) ->
    uid = $(evt.target).closest("[data-uid]").data("uid")
    emailTemplate = @app.collections.emailTemplates.get uid

    @app.views.mainView.templateComposeView.loadEmailTemplate emailTemplate
    @app.views.mainView.templateComposeView.show()

  ############
  ### Move ###
  ############

  setupMoveEmailTemplateDialog: ->
    @moveEmailTemplateDialog =
      @setupDialog ".move-email-template-dialog-form",
        "dialogClass": ".move-email-template-dialog"
        "buttons": [{
          "text": "Cancel"
          "class": "tm_button"
          "click": => @moveEmailTemplateDialog.dialog "close"
        }, {
          "text": "Move"
          "class": "tm_button tm_button-blue"
          "click": => @moveEmailTemplate()
        }]

  moveEmailTemplate: ->
    categoryUID = @ractive.get "selectedCategoryUID"

    @moveEmailTemplateDialog.dialog "close"

    @selectedEmailTemplate.set
      "category_uid": categoryUID

    @selectedEmailTemplate.save null,
      patch: true
      success: (model, response) =>
        @showSuccessOfMoveEmailTemplate()
        @categoriesCollection.fetch()

  showMoveEmailTemplateDialog: (evt) ->
    uid = $(evt.target).closest("[data-uid]").data("uid")
    @selectedEmailTemplate = @app.collections.emailTemplates.get uid
    selectedCategoryUID = if @selectedEmailTemplate.get("category_uid")? then @selectedEmailTemplate.get("category_uid") else ""

    @ractive.set
      "selectedCategoryUID": selectedCategoryUID

    @moveEmailTemplateDialog.dialog("open")

  showSuccessOfMoveEmailTemplate: ->
    TuringEmailApp.showAlert("Email template has been moved successfully!",
      "alert-success",
      3000)

  ##############
  ### Delete ###
  ##############

  onDeleteEmailTemplateClick: (evt) ->
    @app.views.mainView.confirm("Please confirm:").done =>
      uid = $(evt.target).closest("[data-uid]").data("uid")
      emailTemplate = @app.collections.emailTemplates.get uid

      emailTemplate.destroy().then =>
        @app.showAlert("Deleted email template successfully!",
          "alert-success", 3000
        )


  startEditTemplateCategoryTitle: ->
    @categoryNameInEdit = @category.get "name"
    @ractive.set categoryNameInEdit: @categoryNameInEdit

    @$("input.tm_template-toolbar-title").focus()

  finishEditTemplateCategoryTitle: ->
    newName = @ractive.get "categoryNameInEdit"

    # Check if title is empty
    if newName == ""
      @app.showAlert("Please enter a new category title", null, 3000)
      return

    if newName == @category.get("name")
      @cancelEditTemplateCategoryTitle()
      return

    # Check if title already exists
    # The current category is updated due to Ractive's 2-way binding, so we are finding another one with the same name
    if @categoriesCollection.where(name: newName).length > 0
      @app.showAlert("Category with this title already exists", null, 3000)
      return

    @category.set name: newName
    @category.save null,
      patch: true
      success: (model, response) =>
        @app.showAlert("Category has been successfully renamed!", "alert-success", 3000)
        @cancelEditTemplateCategoryTitle()

  cancelEditTemplateCategoryTitle: ->
    @categoryNameInEdit = ""
    @ractive.set categoryNameInEdit: @categoryNameInEdit

  hitEnter: (evt) ->
    if evt.keyCode == 13
      @finishEditTemplateCategoryTitle()