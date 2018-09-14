FactoryGirl.define "EmailAccount", ->
  @sequence("id", "email_address_id")
  @email = "test_" + @email_address_id + "@turinginc.com"
