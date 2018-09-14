describe "ComposeButtonView", ->
  beforeEach ->
    specStartTuringEmailApp()

    emailTemplatesJSON = FactoryGirl.createLists("EmailTemplate", FactoryGirl.SMALL_LIST_SIZE)

    emailTemplates = new TuringEmailApp.Collections.EmailTemplatesCollection()
    emailTemplates.reset(emailTemplatesJSON)

    @composeButtonView = new TuringEmailApp.Views.ComposeButtonView(
      app: TuringEmailApp
      emailTemplates: emailTemplates
    )

  afterEach ->
    specStopTuringEmailApp()

  it "has the right template", ->
    expect(@composeButtonView.template).toEqual JST["backbone/templates/sidebar/compose_button"]
