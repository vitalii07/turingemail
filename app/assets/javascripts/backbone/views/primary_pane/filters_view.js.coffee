TuringEmailApp.Views.PrimaryPane ||= {}
TuringEmailApp.Views.PrimaryPane.Filters ||= {}

class TuringEmailApp.Views.PrimaryPane.Filters.FiltersView extends TuringEmailApp.Views.RactiveView
  template: JST["backbone/templates/primary_pane/filters"]
  className: "tm_content tm_filters-view"


  events: -> _.extend {}, super(),
    "click .create-email-filters-button"    : "showCreateFilterDialog"
    "click .start-edit-email-filter-button" : "showEditFilterDialog"
    "click .delete-email-filter-button"     : "deleteEmailFilter"


  data: -> _.extend {}, super(),
    "dynamic" :
      "emailFilters" : @collection


  initialize: (options) ->
    super options

    @collection = new TuringEmailApp.Collections.EmailFiltersCollection
    @collection.fetch()


  getFilter: (evt) ->
    @collection.get(@$(evt.currentTarget).attr("data-id"))


  showFilterDetailsDialog: (emailFilter) ->
    if emailFilter
      view = TuringEmailApp.views.mainView.filtersComposeView
      view.model = emailFilter
      view.ractive.set "emailFilter" : emailFilter
      view.removeAlert()
      view.show()


  showEditFilterDialog: (evt) ->
    @showFilterDetailsDialog(@getFilter(evt))


  showCreateFilterDialog: ->
    @collection.add({}) unless @collection.last()?.isNew()
    @showFilterDetailsDialog(@collection.last())


  deleteEmailFilter: (evt) ->
    TuringEmailApp.views.mainView.confirm("Please confirm:").done =>
      filter = @getFilter(evt)
      if filter
        filter.destroy()
        TuringEmailApp.showAlert(
          "Filter has been successfully deleted!",
          "alert-success",
          3000
        )
