class TuringEmailApp.Models.Person extends TuringEmailApp.Models.BaseModel
  parse: (response, options) ->
    res = super response, options

    if res?["fullcontact_data"]
      res["fullcontact_data"] = JSON.parse(res["fullcontact_data"])

    res
