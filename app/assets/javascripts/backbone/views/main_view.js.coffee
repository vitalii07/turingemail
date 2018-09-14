class TuringEmailApp.Views.Main extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/main"]

  events:
    "click .tm_compose-button": "compose"
    "click .tm_toptabs a": "updateActiveTab"
    "click .tm_sidebar-right a": "closeRightSidebar"

  initialize: (options) ->
    super(options)

    @app = options.app
    @emailTemplatesJSON = options.emailTemplatesJSON
    @uploadAttachmentPostJSON = options.uploadAttachmentPostJSON

    $(window).resize((evt) => @onWindowResize(evt))

    @toolbarView = new TuringEmailApp.Views.ToolbarView(
      app: @app
    )

  render: ->
    @$el.html(@template({
      userAddress: @app.currentEmailAddress()
      emailAccounts: @app.collections.emailAccounts.toJSON()
    }))

    @primaryPaneDiv = @$(".tm_primary")

    @renderThreadsToolbar()

    @primaryPaneDiv.append('<div class="tm_mail-thread-loading" style="display:block"><svg class="icon busy-indicator"><use xlink:href="/images/symbols.svg#busy-indicator"></use></svg><span>Loading Content</span></div>')

    @sidebarView = new TuringEmailApp.Views.SidebarView(
      app: @app
      el: @$(".tm_sidebar")
    )
    @sidebarView.render()

    if isMobile()
      @composeView = new TuringEmailApp.Views.MobileComposeView(
        app: @app
        primaryPaneDiv: @primaryPaneDiv
        mainView: @
        uploadAttachmentPostJSON: @uploadAttachmentPostJSON
      )
    else
      @composeView = new TuringEmailApp.Views.ModalComposeView(
        app: @app
        el: @$(".compose-view")
        uploadAttachmentPostJSON: @uploadAttachmentPostJSON
      )
      @composeView.render()

    @templateComposeView = new TuringEmailApp.Views.TemplateComposeView(
      app: @app
      el: @$(".template-compose-view")
      categories: @app.collections.emailTemplateCategories
    )
    @templateComposeView.render()

    @filtersComposeView = new TuringEmailApp.Views.FiltersComposeView(
      app: @app
      el: @$(".filters-compose-view")
    )
    @filtersComposeView.render()

    @confirmationView = new TuringEmailApp.Views.ConfirmationView(
      app: @app
      el: @$(".confirmation-view")
    )
    @confirmationView.render()

    @createFolderView = new TuringEmailApp.Views.CreateFolderView(
      app: @app
      el: @$(".create-folder-view")
    )
    @createFolderView.render()

    @attachmentPreviewView = new TuringEmailApp.Views.AttachmentPreviewView(
      app: @app
      el: @$(".attachment-preview-view")
    )
    @attachmentPreviewView.render()

    @resize()

  renderThreadsToolbar: ->
    @primaryPaneDiv.append(@toolbarView.$el)
    @toolbarView.primaryPaneTitle = ""
    @toolbarView.render()

  renderSharedToolbar: (primaryPaneTitle) ->
    @primaryPaneDiv.append(@toolbarView.$el)
    @toolbarView.primaryPaneTitle = primaryPaneTitle
    @toolbarView.render()

  createEmailThreadsListView: (emailThreads) ->
    @emailThreadsListView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.ListView(
      app: @app
      collection: emailThreads
    )

    return @emailThreadsListView

  compose: ->
    @sidebarView.closeSidebarIfMobile()
    @app.views.composeView.show()
    @app.views.composeView.loadEmpty()
    @app.views.composeView.loadEmailSignature()

  composeWithSendLaterDatetime: (sendLaterDatetime) ->
    @compose()
    @app.views.composeView.sendLaterDatetimeIs(sendLaterDatetime)

  composeWithAttachment: (emailAttachment) ->
    @compose()
    @app.views.composeView.addAttachment(emailAttachment)

  loadEmailDelayed: (delayedEmail) ->
    @composeView.show()
    @composeView.loadEmailDelayed(delayedEmail)

  confirm: (message) ->
    @confirmationView.show message

  updateActiveTab: (evt) ->
    @$(".tm_toptabs a.active").removeClass("active")
    $(evt.target).addClass("active")

  closeRightSidebar: (evt) ->
    $("body").removeClass("right-sidebar-open")

  ########################
  ### Resize Functions ###
  ########################

  onWindowResize: (evt) ->
    @resize()

  resize: ->
    @resizeSidebar()
    @resizePrimaryPane()
    @resizePrimarySplitPane()
    @resizeEmailThreadPane()
    @resizeAppsSplitPane()

  resizeSidebar: ->
    return if not @sidebarView?

    height = $(window).height() - @sidebarView.$el.offset().top
    @sidebarView.$el.height(height)

  resizePrimaryPane: ->
    return if not @primaryPaneDiv?

    height = $(window).height() - @primaryPaneDiv.offset().top
    @primaryPaneDiv.height(height)

  resizePrimarySplitPane: ->
    primarySplitPaneDiv = @$(".tm_mail-split-pane")
    return if primarySplitPaneDiv.length is 0

    height = $(window).height() - primarySplitPaneDiv.offset().top
    height = 1 if height <= 0

    primarySplitPaneDiv.height(height)

  resizeEmailThreadPane: ->
    primarySplitPaneDiv = @$(".tm_mail-split-pane")
    return if primarySplitPaneDiv.length is 0

    @trigger "resize:emailThreadPane"

  resizeAppsSplitPane: ->
    appsSplitPaneDiv = @$(".apps_split_pane")
    return if appsSplitPaneDiv.length is 0

    height = $(window).height() - appsSplitPaneDiv.offset().top - 20
    height = 1 if height <= 0

    appsSplitPaneDiv.height(height)

  ######################
  ### View Functions ###
  ######################

  showEmails: (isSplitPaneMode) ->
    return false if not @primaryPaneDiv?

    @primaryPaneDiv.html("")

    emailThreadWrapperView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.EmailThreadWrapperView({
      app: @app
    })
    emailThreadWrapperView.render()

    @renderThreadsToolbar()

    if isSplitPaneMode
      primarySplitPane = $("<div />", {class: "tm_mail-split-pane"}).appendTo(@primaryPaneDiv)

      if @emailThreadsListView.collection.length is 0
        emptyFolderMessageDiv = $("<div />", {class: "tm_mail-box ui-layout-center"}).appendTo(primarySplitPane)
      else
        emailThreadWrapperView.$el.addClass("ui-layout-center")
        primarySplitPane.append(emailThreadWrapperView.$el)

      emailThreadViewDiv = $("<div class='tm_mail-view'><div class='tm_empty-pane'>No conversations selected</div></div>").appendTo(primarySplitPane)

      if @app.models.userConfiguration.get("split_pane_mode") is "horizontal"
        emailThreadViewDiv.addClass("ui-layout-south")
        primarySplitPane.addClass("horizontal-split-pane")
      else if @app.models.userConfiguration.get("split_pane_mode") is "vertical"
        emailThreadViewDiv.addClass("ui-layout-east")
        primarySplitPane.addClass("vertical-split-pane")

      @resizePrimarySplitPane()

      @splitPaneLayout = primarySplitPane.layout({
        applyDefaultStyles: false,
        resizable: true,
        closable: false,
        resizerDragOpacity: 0,
        livePaneResizing: true,
        showDebugMessages: true,
        spacing_open: 1,
        spacing_closed: 1,
        east__minSize: 300,
        south__minSize: 100,

        east__size: if @splitPaneLayout? then @splitPaneLayout.state.east.size else 0.75,
        south__size: if @splitPaneLayout? then @splitPaneLayout.state.south.size else 0.5,
        south__onresize: => @resizeAppsSplitPane()
        east__onresize: => @resizeEmailThreadPane()
      })
    else
      if @emailThreadsListView.collection.length is 0
        emptyFolderMessageDiv = @primaryPaneDiv
      else
        emailThreadWrapperView.$el.addClass("no-split-pane")
        @primaryPaneDiv.append(emailThreadWrapperView.$el)

    if @emailThreadsListView.collection.length is 0
      if @app.selectedEmailFolderID() is "INBOX"
        emptyFolderMessageDiv.append("<div class='tm_empty-pane'>Congratulations on reaching inbox zero!</div>")
      else
        emptyFolderMessageDiv.append("<div class='tm_empty-pane'>There are no conversations with this label</div>")
    else
      @emailThreadsListView.$el = @$(".tm_table-mail-body")
      @emailThreadsListView.render()

    return true

  showAppsLibrary: ->
    return false if not @primaryPaneDiv?

    apps = new TuringEmailApp.Collections.AppsCollection()
    apps.fetch(reset: true)
    appsLibraryView = new TuringEmailApp.Views.PrimaryPane.AppsLibrary.AppsLibraryView({
      collection: apps,
      developer_enabled: @app.models.userConfiguration.get("developer_enabled")
    })
    appsLibraryView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Apps"
    @primaryPaneDiv.append(appsLibraryView.$el)

    return appsLibraryView

  showScheduleEmails: ->
    return false if not @primaryPaneDiv?

    scheduleEmails = new TuringEmailApp.Collections.DelayedEmailsCollection()
    scheduleEmails.fetch(reset: true)

    # Catch "addScheduleEmail" event and add new schedule emails to the collection
    # This will update the schedule email view when the user adds new schedule email
    scheduleEmails.listenTo @composeView, "addScheduleEmail", (scheduleEmail) ->
      @add scheduleEmail

    scheduleEmailsView = new TuringEmailApp.Views.PrimaryPane.ScheduleEmailsView({
      app: @app
      collection: scheduleEmails
    })
    scheduleEmailsView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Scheduled Emails"
    @primaryPaneDiv.append(scheduleEmailsView.$el)

    return scheduleEmailsView

  showEmailReminders: ->
    return false if not @primaryPaneDiv?

    emailRemindersView = new TuringEmailApp.Views.PrimaryPane.EmailRemindersView({
      app: @app
    })
    emailRemindersView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Email Reminders"
    @primaryPaneDiv.append(emailRemindersView.$el)

    return emailRemindersView

  showEmailAttachments: ->
    return false if not @primaryPaneDiv?

    emailAttachments = new TuringEmailApp.Collections.EmailAttachmentsCollection()
    emailAttachments.fetch(
      reset: true
      success: (collection, response, options) =>
        @primaryPaneDiv.find(".tm_mail-email-thread-loading").remove()
    )
    @emailAttachmentsView = new TuringEmailApp.Views.PrimaryPane.EmailAttachmentsView({
      app: @app
      collection: emailAttachments
    })

    @primaryPaneDiv.html('<div class="tm_mail-email-thread-loading" style="display:block"><svg class="icon busy-indicator"><use xlink:href="/images/symbols.svg#busy-indicator"></use></svg><span>Loading Content</span></div>')
    @renderSharedToolbar "Email Attachments"
    @primaryPaneDiv.append(@emailAttachmentsView.$el)

    return @emailAttachmentsView

  showEmailSignatures: (emailSignatureCategoryUID) ->
    return false if not @primaryPaneDiv?

    emailSignatures = new TuringEmailApp.Collections.EmailSignaturesCollection()
    emailSignatures.fetch(reset: true)

    @emailSignaturesView = new TuringEmailApp.Views.PrimaryPane.EmailSignaturesView(
      app: @app
      emailSignatures: emailSignatures
      emailSignatureUID: @app.models.userConfiguration.get("email_signature_uid")
    )
    @emailSignaturesView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Signatures"
    @primaryPaneDiv.append(@emailSignaturesView.$el)

    return @emailSignaturesView

  showEmailTrackers: ->
    return false if not @primaryPaneDiv?

    emailTrackersView = new TuringEmailApp.Views.PrimaryPane.EmailTrackersView({
      app: @app
      collection: @app.collections.emailTrackers
    })
    emailTrackersView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Tracked Emails"
    @primaryPaneDiv.append(emailTrackersView.$el)

    return emailTrackersView

  showEmailTemplates: (emailTemplateCategoryUID) ->
    return false if not @primaryPaneDiv?

    if emailTemplateCategoryUID == "-1" or not emailTemplateCategoryUID
      emailTemplateCategoryUID = ""

    emailTemplatesView = new TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplatesView({
      app: @app
      categoryUID: emailTemplateCategoryUID
    })
    emailTemplatesView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Email Templates"
    @primaryPaneDiv.append(emailTemplatesView.$el)

    return emailTemplatesView

  showEmailTemplateCategories: ->
    return false if not @primaryPaneDiv?

    emailTemplateCategoriesView = new TuringEmailApp.Views.PrimaryPane.EmailTemplates.EmailTemplateCategoriesView({
      app: @app
      collection: @app.collections.emailTemplateCategories
      templatesCollection: @app.collections.emailTemplates
    })
    emailTemplateCategoriesView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Templates"
    @primaryPaneDiv.append(emailTemplateCategoriesView.$el)

    return emailTemplateCategoriesView

  showListSubscriptions: ->
    return false if not @primaryPaneDiv?

    listsSubscribed = new TuringEmailApp.Collections.ListSubscriptionsCollection(undefined,
      unsubscribed: false
    )
    listsUnsubscribed = new TuringEmailApp.Collections.ListSubscriptionsCollection(undefined,
      unsubscribed: true
    )
    listsSubscribed.fetch(reset: true)
    listsUnsubscribed.fetch(reset: true)

    listSubscriptionsView = new TuringEmailApp.Views.PrimaryPane.ListSubscriptionsView({
      listsSubscribed: listsSubscribed
      listsUnsubscribed: listsUnsubscribed
    })
    listSubscriptionsView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Subscriptions"
    @primaryPaneDiv.append(listSubscriptionsView.$el)

    return listSubscriptionsView

  showInboxCleaner: ->
    return false if not @primaryPaneDiv?

    cleanerOverview = new TuringEmailApp.Models.CleanerOverview
    cleanerOverview.fetch(reset: true)
    inboxCleanerView = new TuringEmailApp.Views.PrimaryPane.InboxCleanerView({
      app: @app
      model: cleanerOverview
    })

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Inbox Cleaner"
    @primaryPaneDiv.append(inboxCleanerView.render().$el)

    return inboxCleanerView

  showInboxCleanerReport: ->
    return false if not @primaryPaneDiv?

    cleanerReport = new TuringEmailApp.Models.CleanerReport()
    cleanerReport.save()
    inboxCleanerReportView = new TuringEmailApp.Views.PrimaryPane.InboxCleanerReportView({
      app: @app
      model: cleanerReport
    })

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Inbox Cleaner Report"
    @primaryPaneDiv.append(inboxCleanerReportView.render().$el)

    return inboxCleanerReportView

  showContactInbox: ->
    return false if not @primaryPaneDiv?

    contactInboxView =
      new TuringEmailApp.Views.PrimaryPane.EmailConversations.ContactInboxView({
        app: @app
      })
    contactInboxView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Conversations"

    @primaryPaneDiv.append(contactInboxView.$el)

    @resizePrimarySplitPane()

    contactInboxView.setupSplitPane()

    return contactInboxView

  showSettings: ->
    return false if not @primaryPaneDiv?

    settingsView = new TuringEmailApp.Views.PrimaryPane.Settings.SettingsView(
      app: @app
      model: @app.models.userConfiguration
    )
    settingsView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Settings"
    @primaryPaneDiv.append(settingsView.$el)

    return settingsView

  showDashboard: ->
    return false if not @primaryPaneDiv?

    dashboard = new TuringEmailApp.Models.Dashboard()
    dashboard.fetch(reset: true)

    @dashboardView = new TuringEmailApp.Views.PrimaryPane.DashboardView(
      app: @app
      model: dashboard
    )
    @dashboardView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Dashboard"
    @primaryPaneDiv.append(@dashboardView.$el)

    return @dashboardView

  showFilters: ->
    return false if not @primaryPaneDiv?

    filtersView = new TuringEmailApp.Views.PrimaryPane.Filters.FiltersView()
    filtersView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Filters"
    @primaryPaneDiv.append(filtersView.$el)

    return filtersView

  showAnalytics: ->
    return false if not @primaryPaneDiv?

    analyticsView = new TuringEmailApp.Views.PrimaryPane.Analytics.AnalyticsView()
    analyticsView.render()

    @primaryPaneDiv.html("")
    @renderSharedToolbar "Analytics"
    @primaryPaneDiv.append(analyticsView.$el)

    return analyticsView

  showReport: (ReportModel, ReportView) ->
    return false if not @primaryPaneDiv?

    reportModel = new ReportModel()
    reportView = new ReportView(
      model: reportModel
    )

    @primaryPaneDiv.html("")
    @primaryPaneDiv.append(reportView.$el)

    reportModel.fetch(reset: true)

    return reportView

  showEmailThread: (emailThread, isSplitPaneMode) ->
    return false if not @primaryPaneDiv?

    @stopListening(@currentEmailThreadView) if @currentEmailThreadView?
    @currentEmailThreadView = emailThreadView = new TuringEmailApp.Views.PrimaryPane.EmailThreads.EmailThreadView(
      app: @app
      model: emailThread
      emailTemplatesJSON: @emailTemplatesJSON
      uploadAttachmentPostJSON: @uploadAttachmentPostJSON
    )

    if isSplitPaneMode
      emailThreadViewDiv = @$(".tm_mail-view")

      if emailThreadViewDiv.length is 0
        @showEmails(isSplitPaneMode)
        emailThreadViewDiv = @$(".tm_mail-view")
    else
      emailThreadViewDiv = @primaryPaneDiv

    emailThreadViewDiv.html("")

    if @app.models.userConfiguration?.get("installed_apps")?.length > 0
      appsSplitPane = $("<div />", {class: "apps_split_pane"}).appendTo(emailThreadViewDiv)

      emailThreadView.$el.addClass("ui-layout-center")
      appsSplitPane.append(emailThreadView.$el)
      emailThreadView.render()

      appsDiv = $("<div />").appendTo(appsSplitPane)
      appsDiv.addClass("ui-layout-east")
      appsDiv.attr("style", "overflow: hidden !important; padding: 0px !important;")

      @runApps(appsDiv, emailThread) if emailThread?
      @listenTo(@currentEmailThreadView, "expand:email", (emailThreadView, emailJSON) => @runApps(appsDiv, emailJSON))

      @resizeAppsSplitPane()

      appsSplitPane.layout({
        applyDefaultStyles: true,
        resizable: false,
        closable: false,
        livePaneResizing: true,
        showDebugMessages: true,

        east__size: 200
      })
    else
      emailThreadViewDiv.off("resize")
      emailThreadViewDiv.html(emailThreadView.$el)
      emailThreadView.render()

    if not isSplitPaneMode
      emailThreadViewDiv.prepend(@toolbarView.$el)
      @toolbarView.render()
      emailThreadView.$el.wrap("<div class='tm_content'></div>")

    return emailThreadView

  runApps: (appsDiv, object) ->
    appsDiv.html("")

    for installedAppJSON in @app.models.userConfiguration.get("installed_apps")
      appIframe = $("<iframe></iframe>").appendTo(appsDiv)
      appIframe.css("width", "100%")
      appIframe.css("height", "100%")
      installedApp = TuringEmailApp.Models.InstalledApps.InstalledApp.CreateFromJSON(installedAppJSON)
      installedApp.run(appIframe, object)

  showWelcomeTour: ->
    @tourView = new TuringEmailApp.Views.TourView(
      el: @$(".tour-view")
    )
    @tourView.render()

  showAbout: ->
    @aboutView = new TuringEmailApp.Views.AboutView(
      el: @$(".about-view")
    )
    @aboutView.render()

  showFAQ: ->
    @faqView = new TuringEmailApp.Views.FAQView(
      el: @$(".faq-view")
    )
    @faqView.render()

  showPrivacy: ->
    @privacyView = new TuringEmailApp.Views.PrivacyView(
      el: @$(".privacy-view")
    )
    @privacyView.render()

  showTerms: ->
    @termsView = new TuringEmailApp.Views.TermsView(
      el: @$(".terms-view")
    )
    @termsView.render()
