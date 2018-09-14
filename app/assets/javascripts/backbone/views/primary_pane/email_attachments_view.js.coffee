TuringEmailApp.Views.PrimaryPane ||= {}

class TuringEmailApp.Views.PrimaryPane.EmailAttachmentsView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/email_attachments"]

  events:
    "click .tm_attachment-table a.tm_datagrid-sort[data-order-by]" : "orderBy"
    "click .tm_attachment-toolbar .tm_content-tabs a" : "filterByType"
    "click .view-mode-table": "setTableMode"
    "click .view-mode-gallery": "setGalleryMode"
    "click .preview-attachment-button": "previewAttachment"
    "click .download-attachment-button": "downloadAttachment"
    "click .share-attachment-button": "shareAttachment"
    "click .delete-attachment-button": "deleteAttachment"

  className: "tm_content"

  initialize: (options) ->
    super(options)

    @app = options.app
    @typeFilters =
      "all": "All"
      "image": "Image"
      "document": "Document"
      "other": "Other"
    @orderFields =
      "name": "Name"
      "size": "File Size"
      "subject": "Subject"
      "date": "Date"

    @orderField = @collection.order_by
    @orderDir = @collection.dir
    @typeFilter = "all"
    @viewMode = "table"
    @filteredCollection = null
    @prevFilteredCollectionCount = 0

    @attachmentsReport = new TuringEmailApp.Models.Reports.AttachmentsReport()
    @attachmentsReportFetched = @attachmentsReport.fetch reset: true

    @listenTo(@collection, "reset", @render)

  data: -> _.extend {}, super(),
    "dynamic":
      "typeFilters": @typeFilters
      "typeFilter": @typeFilter
      "orderFields": @orderFields
      "orderField": @orderField
      "orderDir": @orderDir
      "viewMode": @viewMode      

  render: ->
    @$el.html('<div class="tm_mail-attachments-loading" style="display:block"><svg class="icon busy-indicator"><use xlink:href="/images/symbols.svg#busy-indicator"></use></svg><span>Loading Content</span></div>')

    @attachmentsReportFetched.done =>
      super()

      counts = @attachmentsReport.getCountsByFileType()

      # Update count of previous filtered collection for fly-down transition
      if @prevFilteredCollectionCount > 0
        @prevFilteredCollectionCount = @filteredCollection.length

      @filteredCollection = if @typeFilter == "all" then @collection else @collection.filterByType(@typeFilter)

      @ractive.set
        "counts": counts
        "prevFilteredCollectionCount": @prevFilteredCollectionCount
        "emailAttachments": @filteredCollection

      @setupMasonry()
      @setupInfiniteScroll()

    @

  orderBy: (evt) ->
    nextOrderDir =
      "ASC": "DESC"
      "DESC": "ASC"
    selectedOrder = $(evt.currentTarget).data("order-by")
    if selectedOrder == @orderField
      @orderDir = nextOrderDir[@orderDir]
    else
      @orderField = selectedOrder
      @orderDir = "ASC"

    @collection.order_by = @orderField
    @collection.dir = @orderDir

    # TODO: We should use client sorting here.
    # If we fetch from the server for the sorted result, it fetches only the first page
    @collection.fetch(
      success: (model, response, options) =>
        @render()
    )

  filterByType: (evt) ->
    # TODO: make server filtering working, now we are using client filtering so.
#    @collection.type = $(evt.currentTarget).data("attachment-type")
#    @collection.fetch(
#      success: (model, response, options) =>
#        @render()
#
#        #Update styles
#        @$(".tm_attachment-toolbar a").removeClass("active")
#        $(evt.currentTarget).addClass("active")
#    )
    filter = $(evt.currentTarget).data("attachment-type")
    # if type filter changed, set the count of previous filtered collection 0, and rerender
    if @typeFilter != filter
      @prevFilteredCollectionCount = 0
      @typeFilter = filter
      @render()

  setTableMode: ->
    @viewMode = "table"
    @ractive.set "viewMode", @viewMode

  setGalleryMode: ->
    @viewMode = "gallery"
    @ractive.set "viewMode", @viewMode
    @setupMasonry()

  setupMasonry: ->
    @$('.tm_attachment-gallery').masonry
      itemSelector: '.item'
      transitionDuration: '0.2s'
      percentPosition: true

  setupInfiniteScroll: ->
    $(window).resize () ->
      $(".tm_attachment-scrollview").css("height", $(window).height() - 270)
    .resize()

    loadingIndicator = $(".tm_mail-box-loading").hide()
    @infiniteScrollTriggerable = true if not @infiniteScrollTriggerable?
    $(".tm_attachment-scrollview").scroll =>
      emailAttachmentScrollview = $(".tm_attachment-scrollview")
      if @infiniteScrollTriggerable
        if emailAttachmentScrollview.scrollTop() + emailAttachmentScrollview.height() > emailAttachmentScrollview.get(0).scrollHeight - 50
          currentScrollTop = emailAttachmentScrollview.scrollTop()
          @infiniteScrollTriggerable = false
          @collection.page += 1
          @collection.fetch(
            remove: false
            success: (collection, response, options) =>
              @render()
              $(".tm_attachment-scrollview").scrollTop currentScrollTop
          )
          loadingIndicator.show()

      if emailAttachmentScrollview.scrollTop() + emailAttachmentScrollview.height() < emailAttachmentScrollview.get(0).scrollHeight - 250
        @infiniteScrollTriggerable = true

  previewAttachment: (evt) ->
    uid = $(evt.currentTarget).closest("[data-uid]").data("uid")
    emailAttachment = @collection.get(uid)
    @app.views.mainView.attachmentPreviewView.loadEmailAttachment(emailAttachment)
    @app.views.mainView.attachmentPreviewView.show()

  downloadAttachment: (evt) ->
    uid = $(evt.currentTarget).closest("[data-uid]").data("uid")
    emailAttachment = @collection.get(uid)

    if emailAttachment
      TuringEmailApp.Models.EmailAttachment.Download @app, uid

  shareAttachment: (evt) ->
    uid = $(evt.currentTarget).closest("[data-uid]").data("uid")
    emailAttachment = @collection.get(uid)

    if emailAttachment
      TuringEmailApp.views.mainView.composeWithAttachment(emailAttachment)

  deleteAttachment: (evt) ->
    @
