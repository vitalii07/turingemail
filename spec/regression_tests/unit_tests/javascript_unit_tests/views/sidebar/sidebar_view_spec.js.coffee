describe "SidebarView", ->
  beforeEach ->
    @sidebarView = new TuringEmailApp.Views.SidebarView(
      app: TuringEmailApp
    )

  it "has the right template", ->
    expect(@sidebarView.template).toEqual JST["backbone/templates/sidebar/sidebar"]
