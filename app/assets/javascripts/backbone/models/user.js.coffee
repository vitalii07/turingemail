class TuringEmailApp.Models.User extends TuringEmailApp.Models.BaseModel
  url: "/api/v1/users/current"

  validation:
    email:
      required: true
      pattern: "email"

    profile_picture:
      required: true
      pattern: "url"

    num_emails:
      required: true
      min: 0
