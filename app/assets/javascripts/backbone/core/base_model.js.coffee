class TuringEmailApp.Models.BaseModel extends Backbone.Model
  sync: (method, model, options) ->
    super method, model, _.extend({}, options, "url" : @syncUrl(model, options))


_.extend(
  TuringEmailApp.Models.BaseModel.prototype,
  TuringEmailApp.Mixins.EmailAccountUtils
)
