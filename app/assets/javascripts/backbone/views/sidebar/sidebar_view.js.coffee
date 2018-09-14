class TuringEmailApp.Views.SidebarView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/sidebar/sidebar"]

  initialize: (options) ->
    super(options)

    @app = options.app

  render: ->
    profilePicture = if @app.models.user.get("profile_picture")? then @app.models.user.get("profile_picture") else false

    @$el.html(@template(name: @app.models.user.get("name"), profilePicture: profilePicture, userAddress: @app.currentEmailAddress()))

    @composebuttonview = new TuringEmailApp.Views.ComposeButtonView(
      app: @app
      el: @$(".tm_email-compose")
      emailTemplates: @app.collections.emailTemplates
    )
    @composebuttonview.render()

    @

  closeSidebarIfMobile: ->
    $("body").removeClass("sidebar-open") if isMobile()
