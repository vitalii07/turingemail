class TuringEmailApp.Collections.BaseCollection extends Backbone.Collection
  initialize: (models, options) ->
    @listenTo(this, "remove", @modelRemoved)
    @listenTo(this, "reset", @modelsReset)


  sync: (method, model, options) ->
    super method, model, _.extend({}, options, "url" : @syncUrl(model, options))


  ##############
  ### Events ###
  ##############

  modelRemoved: (model) ->
    model.trigger("removedFromCollection", this)


  modelsReset: (models, options) ->
    options.previousModels.forEach(@modelRemoved, this)


_.extend(
  TuringEmailApp.Collections.BaseCollection.prototype,
  TuringEmailApp.Mixins.EmailAccountUtils
)
