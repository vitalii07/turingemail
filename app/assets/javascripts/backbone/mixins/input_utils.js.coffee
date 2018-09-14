TuringEmailApp.Mixins ||= {}


TuringEmailApp.Mixins.InputUtils =
  splitInputString: (val) ->
    if _.isString(val) then val.split(/[;, ]+/) else val


TuringEmailApp.Mixins.InputUtils.arrayInputConverter =
  "get": "${_}.join(\", \")"
  "set": TuringEmailApp.Mixins.InputUtils.splitInputString


_.extend TuringEmailApp.Mixins, TuringEmailApp.Mixins.InputUtils
