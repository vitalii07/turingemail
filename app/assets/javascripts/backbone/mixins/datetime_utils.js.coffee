TuringEmailApp.Mixins ||= {}

_.extend TuringEmailApp.Mixins,
  formatDate: (d) ->
    new Date(d).toLocaleString(navigator.language, {month: 'short', day: 'numeric', year: 'numeric'})

  formatTime: (d) ->
    new Date(d).toLocaleString(navigator.language, {hour: '2-digit', minute: '2-digit'})