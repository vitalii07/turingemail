class TuringEmailApp.Views.TourView extends TuringEmailApp.Views.BaseView
  template: JST["backbone/templates/tour/tour"]

  events: -> _.extend {}, super(),
    "click .tm_tour-skip": "hide"
    "click .tm_tour-prev": "prev"
    "click .tm_tour-next": "next"
    "click .tm_tour-chapter": "goto"

  render: ->
    @$el.html(@template())

    @show()
    @hidePrev()

    @

  #################
  ### Show/Hide ###
  #################

  show: ->
    @$(".tour-modal").modal(
      backdrop: 'static'
      keyboard: false
      show: false
    ).on("shown.bs.modal", ->
      $(".tm_tour", this).addClass("animate")
    ).modal('show')

  hide: ->
    @$(".tour-modal").modal "hide"
    if not isMobile()
      @featuretour()

  showNext: ->
    @$(".tm_tour-next").show()

  hideNext: ->
    @$(".tm_tour-next").hide()

  showPrev: ->
    @$(".tm_tour-prev").show()

  hidePrev: ->
    @$(".tm_tour-prev").hide()

  showSlide: (index) ->
    $slides = @$(".tm_tour-slide")
    slidesCount = $slides.length - 1
    index = Math.max(0, Math.min(slidesCount, index))

    @$(".tm_tour-chapters").toggleClass("visible", index >= 2)
      .children().removeClass("active").eq(index - 2).addClass("active")

    $slides.removeClass("active").eq(index).addClass("active")

    if index == 0 then @hidePrev() else @showPrev()
    if index == slidesCount
      @hideNext()
      @hidePrev()
      @$(".skip-tour-text").text("End Tour")
    else
      @showNext()
      @$(".skip-tour-text").text("Skip Tour")

  #################
  ### Next/Prev ###
  #################

  #TODO parametrize into more concise method.

  goto: (e) ->
    @showSlide $(e.currentTarget).index() + 2

  next: ->
    @showSlide @$(".tm_tour-slide.active").index() + 1

  prev: ->
    @showSlide @$(".tm_tour-slide.active").index() - 1

  ####################
  ### Feature Tour ###
  ####################

  featuretour: ->
    tour = new Tour({
      steps: [
        {
          element: ".tm_compose-button",
          placement: "right",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#sidebar-compose'></use></svg> The Initiation.",
          content: "Click <span>Compose</span> to learn the fundamentals of Turing. <small>1 of 10</small>",
          reflex: true,
          backdrop: true,
          onShow: (tour) -> $('.tm_compose-button').addClass "highlight"
          onHide: (tour) -> $('.tm_compose-button').removeClass "highlight"
        },
        {
          element: ".compose-view .redactor-toolbar",
          placement: "bottom",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#sidebar-compose'></use></svg> Compose",
          content: "Welcome to compose, where all your outgoing email actions originate. <small>2 of 10</small>",
          delay: 600,
          onShow: (tour) -> $('.tm_compose-modal-header').css('pointer-events', 'none')
          onHide: (tour) -> $('.tm_compose-modal-header').css('pointer-events', '')
        },
        {
          element: ".compose-view .tm_compose-footer > .dropdown",
          placement: "top",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#tour-bell'></use></svg> Set a Reminder",
          content: "to know when someone hasn’t replyed to an email. Practice setting a reminder. <small>3 of 10</small>",
          autoscroll: false,
          onShow: (tour) ->
            $('.tm_compose-modal-header').css('pointer-events', 'none')
            $('.tm_modal-body-compose').addClass "backdrop"
            $('.compose-view .tm_compose-footer > .dropdown label').addClass "highlight"
          onHide: (tour) ->
            $('.tm_compose-modal-header').css('pointer-events', '')
            $('.tm_modal-body-compose').removeClass "backdrop"
            $('.compose-view .tm_compose-footer > .dropdown label').removeClass "highlight"
        },
        {
          element: ".compose-view .tm_compose-modal-tracking",
          placement: "top",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#tour-track'></use></svg> Track an Email",
          content: "to know when someone has opened an email. Practice tracking an email. <small>4 of 10</small>",
          autoscroll: false,
          onShow: (tour) ->
            $('.tm_compose-modal-header').css('pointer-events', 'none')
            $('.tm_modal-body-compose').addClass "backdrop"
            $('.compose-view .tm_compose-modal-tracking label').addClass "highlight"
          onHide: (tour) ->
            $('.tm_compose-modal-header').css('pointer-events', '')
            $('.tm_modal-body-compose').removeClass "backdrop"
            $('.compose-view .tm_compose-modal-tracking label').removeClass "highlight"
        },
        {
          element: ".compose-view .send-later-datetimepicker",
          placement: "top",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#tour-schedule'></use></svg> Schedule an Email",
          content: "for the perfect arrival time. Practice setting the arrival time and date. <small>5 of 10</small>",
          autoscroll: false,
          onShow: (tour) ->
            $('.tm_compose-modal-header').css('pointer-events', 'none')
            $('.tm_modal-body-compose').addClass "backdrop"
            $('.compose-view .send-later-datetimepicker').addClass "highlight"
          onHide: (tour) ->
            $('.tm_compose-modal-header').css('pointer-events', '')
            $('.tm_modal-body-compose').removeClass "backdrop"
            $('.compose-view .send-later-datetimepicker').removeClass "highlight"
        },
        {
          element: "#emailTemplatesDropdownMenu",
          placement: "bottom",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#tour-compose'></use></svg> Template Management",
          content: "Create new templates and load saved templates. <small>6 of 10</small>",
          onShow: (tour) ->
            $('.tm_compose-modal-header').css('pointer-events', 'none')
            $('.tm_modal-body-compose').addClass "backdrop"
          onHide: (tour) ->
            $('.tm_compose-modal-header').css('pointer-events', '')
            $('.tm_modal-body-compose').removeClass "backdrop"
          onNext: (tour) -> $('.compose-modal-close-toggle').click()
        },
        {
          element: ".tm_compose-dropdown",
          placement: "right",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#tour-compose'></use></svg> Quick Compose",
          content: "Load your templates quickly from the main tool bar. <small>7 of 10</small>",
          backdrop: true,
          onShow: (tour) -> $('.tm_compose-dropdown').addClass "highlight"
          onHide: (tour) -> $('.tm_compose-dropdown').removeClass "highlight"
        },
        {
          element: ".tm_folder-scheduled",
          placement: "right",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#tour-schedule'></use></svg> Follow Up",
          content: "See the current status of Scheduled and Tracked emails here. <small>8 of 10</small>",
          backdrop: true,
          onShow: (tour) ->
            $('.tm_folder-scheduled').addClass "highlight"
            $('.tm_folder-tracked').addClass "highlight"
          onHide: (tour) ->
            $('.tm_folder-scheduled').removeClass "highlight"
            $('.tm_folder-tracked').removeClass "highlight"
        },
        {
          element: ".tm_folder-contact",
          placement: "right",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#tour-conversation'></use></svg> Conversations",
          content: "Send and receive emails like instant messages in the Conversations Inbox. <small>9 of 10</small>",
          backdrop: true,
          onShow: (tour) -> $('.tm_folder-contact').addClass "highlight"
          onHide: (tour) -> $('.tm_folder-contact').removeClass "highlight"
        },
        {
          element: ".tm_mail-context-sidebar",
          placement: "left",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#sidebar-contact'></use></svg> Contact Sidebar",
          content: "View details about your contacts including latest tweets and emails. <small>10 of 10</small>",
          backdrop: true,
          onShow: (tour) -> $('.tm_mail-view.ui-layout-east').css('z-index', 'initial')
        },
        {
          element: "body",
          placement: "top",
          title: "<svg class='figure'><use xlink:href='/images/symbols.svg#checkmark'></use></svg> That’s it.",
          content: "You’re ready to get started with the basic features of Turing Email.",
          backdrop: true
        },
      ]
    })

    tour.init()
    tour.restart()
    @$(".modal-backdrop").remove()

  class Tour
    constructor: (options) ->
      try
        storage = window.localStorage
      catch
        storage = false
      @_options = $.extend
        name: 'tour'
        steps: []
        container: 'body'
        autoscroll: true
        keyboard: true
        storage: storage
        debug: false
        backdrop: false
        backdropPadding: 0
        redirect: true
        orphan: false
        duration: false
        delay: false
        basePath: ''
        template: '<div class="popover" role="tooltip">
          <div class="arrow"></div>
          <h3 class="popover-title"></h3>
          <div class="popover-content"></div>
          <div class="popover-navigation">
            <div class="btn-group">
              <a data-role="end">Close Tour</a>
              <a class="btn-next" data-role="next">Next &gt;</a>
            </div>
          </div>
        </div>'
        afterSetState: (key, value) ->
        afterGetState: (key, value) ->
        afterRemoveState: (key) ->
        onStart: (tour) ->
        onEnd: (tour) ->
        onShow: (tour) ->
        onShown: (tour) ->
        onHide: (tour) ->
        onHidden: (tour) ->
        onNext: (tour) ->
        onPrev: (tour) ->
        onPause: (tour, duration) ->
        onResume: (tour, duration) ->
      , options

      @_force = false
      @_inited = false
      @backdrop =
        overlay: null
        $element: null
        $background: null
        backgroundShown: false
        overlayElementShown: false
      @

    addSteps: (steps) ->
      @addStep step for step in steps
      @

    addStep: (step) ->
      @_options.steps.push step
      @

    getStep: (i) ->
      if @_options.steps[i]?
        $.extend
          id: "step-#{i}"
          path: ''
          placement: 'right'
          title: ''
          content: '<p></p>'
          next: if i is @_options.steps.length - 1 then -1 else i + 1
          prev: i - 1
          animation: true
          container: @_options.container
          autoscroll: @_options.autoscroll
          backdrop: @_options.backdrop
          backdropPadding: @_options.backdropPadding
          redirect: @_options.redirect
          orphan: @_options.orphan
          duration: @_options.duration
          delay: @_options.delay
          template: @_options.template
          onShow: @_options.onShow
          onShown: @_options.onShown
          onHide: @_options.onHide
          onHidden: @_options.onHidden
          onNext: @_options.onNext
          onPrev: @_options.onPrev
          onPause: @_options.onPause
          onResume: @_options.onResume
        , @_options.steps[i]

    init: (force) ->
      @_force = force

      if @ended()
        @_debug 'Tour ended, init prevented.'
        return @

      @setCurrentStep()

      @_initMouseNavigation()
      @_initKeyboardNavigation()

      @_onResize => @showStep @_current

      @showStep @_current unless @_current is null

      @_inited = true
      @

    start: (force = false) ->
      @init force unless @_inited

      if @_current is null
        promise = @_makePromise(@_options.onStart(@) if @_options.onStart?)
        @_callOnPromiseDone(promise, @showStep, 0)
      @

    next: ->
      promise = @hideStep @_current
      @_callOnPromiseDone promise, @_showNextStep

    prev: ->
      promise = @hideStep @_current
      @_callOnPromiseDone promise, @_showPrevStep

    goTo: (i) ->
      promise = @hideStep @_current
      @_callOnPromiseDone promise, @showStep, i

    end: ->
      endHelper = (e) =>
        $(document).off "click.tour-#{@_options.name}"
        $(document).off "keyup.tour-#{@_options.name}"
        $(window).off "resize.tour-#{@_options.name}"
        @_setState('end', 'yes')
        @_inited = false
        @_force = false

        @_clearTimer()

        @_options.onEnd(@) if @_options.onEnd?

      promise = @hideStep(@_current)
      @_callOnPromiseDone(promise, endHelper)

    ended: ->
      not @_force and not not @_getState 'end'

    restart: ->
      @_removeState 'current_step'
      @_removeState 'end'
      @start()

    pause: ->
      step = @getStep @_current
      return @ unless step and step.duration

      @_paused = true
      @_duration -= new Date().getTime() - @_start
      window.clearTimeout(@_timer)

      @_debug "Paused/Stopped step #{@_current + 1} timer (#{@_duration} remaining)."

      step.onPause @, @_duration if step.onPause?

    resume: ->
      step = @getStep @_current
      return @ unless step and step.duration

      @_paused = false
      @_start = new Date().getTime()
      @_duration = @_duration or step.duration
      @_timer = window.setTimeout =>
        if @_isLast() then @next() else @end()
      , @_duration

      @_debug "Started step #{@_current + 1} timer with duration #{@_duration}"

      step.onResume @, @_duration if step.onResume? and @_duration isnt step.duration

    hideStep: (i) ->
      step = @getStep i
      return unless step

      @_clearTimer()

      promise = @_makePromise(step.onHide @, i if step.onHide?)

      hideStepHelper = (e) =>
        $element = $ step.element
        $element = $('body') unless $element.data('bs.popover') or $element.data('popover')
        $element
        .popover('destroy')
        .removeClass "tour-#{@_options.name}-element tour-#{@_options.name}-#{i}-element"
        if step.reflex
          $element
          .removeClass('tour-step-element-reflex')
          .off "#{@_reflexEvent(step.reflex)}.tour-#{@_options.name}"

        @_hideBackdrop() if step.backdrop

        step.onHidden(@) if step.onHidden?

      @_callOnPromiseDone promise, hideStepHelper
      promise

    showStep: (i) ->
      if @ended()
        @_debug 'Tour ended, showStep prevented.'
        return @

      step = @getStep i
      return unless step

      skipToPrevious = i < @_current

      promise = @_makePromise(step.onShow @, i if step.onShow?)

      showStepHelper = (e) =>
        @setCurrentStep i

        path = switch ({}).toString.call step.path
          when '[object Function]' then step.path()
          when '[object String]' then @_options.basePath + step.path
          else step.path

        current_path = [document.location.pathname, document.location.hash].join('')
        if @_isRedirect path, current_path
          @_redirect step, path
          return

        if @_isOrphan step
          if not step.orphan
            @_debug """Skip the orphan step #{@_current + 1}.
            Orphan option is false and the element does not exist or is hidden."""
            if skipToPrevious then @_showPrevStep() else @_showNextStep()
            return

          @_debug "Show the orphan step #{@_current + 1}. Orphans option is true."

        @_showBackdrop(step.element unless @_isOrphan step) if step.backdrop

        showPopoverAndOverlay = =>
          return if @getCurrentStep() isnt i

          @_showOverlayElement step if step.element? and step.backdrop
          @_showPopover step, i
          step.onShown @ if step.onShown?
          @_debug "Step #{@_current + 1} of #{@_options.steps.length}"

        if step.autoscroll
          @_scrollIntoView step.element, showPopoverAndOverlay
        else
          showPopoverAndOverlay()

        @resume() if step.duration

      if step.delay
        @_debug "Wait #{step.delay} milliseconds to show the step #{@_current + 1}"
        window.setTimeout =>
          @_callOnPromiseDone promise, showStepHelper
        , step.delay
      else
        @_callOnPromiseDone promise, showStepHelper

      promise

    getCurrentStep: ->
      @_current

    setCurrentStep: (value) ->
      if value?
        @_current = value
        @_setState 'current_step', value
      else
        @_current = @_getState 'current_step'
        @_current = if @_current is null then null else parseInt @_current, 10
      @

    _setState: (key, value) ->
      if @_options.storage
        keyName = "#{@_options.name}_#{key}"
        try @_options.storage.setItem keyName, value
        catch e
          if e.code is DOMException.QUOTA_EXCEEDED_ERR
            @_debug 'LocalStorage quota exceeded. State storage failed.'
        @_options.afterSetState keyName, value
      else
        @_state ?= {}
        @_state[key] = value

    _removeState: (key) ->
      if @_options.storage
        keyName = "#{@_options.name}_#{key}"
        @_options.storage.removeItem keyName
        @_options.afterRemoveState keyName
      else
        delete @_state[key] if @_state?

    _getState: (key) ->
      if @_options.storage
        keyName = "#{@_options.name}_#{key}"
        value = @_options.storage.getItem keyName
      else
        value = @_state[key] if @_state?

      value = null if value is undefined or value is 'null'

      @_options.afterGetState key, value
      return value

    _showNextStep: ->
      step = @getStep @_current
      showNextStepHelper = (e) => @showStep step.next

      promise = @_makePromise(step.onNext @ if step.onNext?)
      @_callOnPromiseDone promise, showNextStepHelper

    _showPrevStep: ->
      step = @getStep @_current
      showPrevStepHelper = (e) => @showStep step.prev

      promise = @_makePromise(step.onPrev @ if step.onPrev?)
      @_callOnPromiseDone promise, showPrevStepHelper

    _debug: (text) ->
      window.console.log "Bootstrap Tour '#{@_options.name}' | #{text}" if @_options.debug

    _isRedirect: (path, currentPath) ->
      path? and path isnt '' and (
        (({}).toString.call(path) is '[object RegExp]' and not path.test currentPath) or
        (({}).toString.call(path) is '[object String]' and
          path.replace(/\?.*$/, '').replace(/\/?$/, '') isnt currentPath.replace(/\/?$/, ''))
      )

    _redirect: (step, path) ->
      if $.isFunction step.redirect
        step.redirect.call this, path
      else if step.redirect is true
        @_debug "Redirect to #{path}"
        document.location.href = path

    _isOrphan: (step) ->
      not step.element? or
      not $(step.element).length or
      $(step.element).is(':hidden') and
      ($(step.element)[0].namespaceURI isnt 'http://www.w3.org/2000/svg')

    _isLast: ->
      @_current < @_options.steps.length - 1

    _showPopover: (step, i) ->
      $(".tour-#{@_options.name}").remove()

      options = $.extend {}, @_options
      isOrphan = @_isOrphan step

      step.template = @_template step, i

      if isOrphan
        step.element = 'body'
        step.placement = 'top'

      $element = $ step.element
      $element.addClass "tour-#{@_options.name}-element tour-#{@_options.name}-#{i}-element"

      $.extend options, step.options if step.options
      if step.reflex and not isOrphan
        $element.addClass('tour-step-element-reflex')
        $element.off("#{@_reflexEvent(step.reflex)}.tour-#{@_options.name}")
        $element.on "#{@_reflexEvent(step.reflex)}.tour-#{@_options.name}", =>
          if @_isLast() then @next() else @end()

      $element
      .popover(
        placement: step.placement
        trigger: 'manual'
        title: step.title
        content: step.content
        html: true
        animation: step.animation
        container: step.container
        template: step.template
        selector: step.element
      )
      .popover 'show'

      $tip = if $element.data 'bs.popover' then $element.data('bs.popover').tip() else $element.data('popover').tip()
      $tip.attr 'id', step.id
      @_reposition $tip, step
      @_center $tip if isOrphan

    _template: (step, i) ->
      $template = if $.isFunction step.template then $(step.template i, step) else $(step.template)
      $navigation = $template.find '.popover-navigation'
      $prev = $navigation.find '[data-role="prev"]'
      $next = $navigation.find '[data-role="next"]'
      $resume = $navigation.find '[data-role="pause-resume"]'

      $template.addClass 'orphan' if @_isOrphan step
      $template.addClass "tour-#{@_options.name} tour-#{@_options.name}-#{i}"
      $prev.addClass('disabled') if step.prev < 0
      $next.addClass('disabled') if step.next < 0
      $resume.remove() unless step.duration
      $template.clone().wrap('<div>').parent().html()

    _reflexEvent: (reflex) ->
      if ({}).toString.call(reflex) is '[object Boolean]' then 'click' else reflex

    _reposition: ($tip, step) ->
      offsetWidth = $tip[0].offsetWidth
      offsetHeight = $tip[0].offsetHeight

      tipOffset = $tip.offset()
      originalLeft = tipOffset.left
      originalTop = tipOffset.top
      offsetBottom = $(document).outerHeight() - tipOffset.top - $tip.outerHeight()
      tipOffset.top = tipOffset.top + offsetBottom if offsetBottom < 0
      offsetRight = $('html').outerWidth() - tipOffset.left - $tip.outerWidth()
      tipOffset.left = tipOffset.left + offsetRight if offsetRight < 0

      tipOffset.top = 0 if tipOffset.top < 0
      tipOffset.left = 0 if tipOffset.left < 0

      $tip.offset(tipOffset)

      if step.placement is 'bottom' or step.placement is 'top'
        if originalLeft isnt tipOffset.left
          @_replaceArrow $tip, (tipOffset.left - originalLeft) * 2, offsetWidth, 'left'
      else
        if originalTop isnt tipOffset.top
          @_replaceArrow $tip, (tipOffset.top - originalTop) * 2, offsetHeight, 'top'

    _center: ($tip) ->
      $tip.css('top', $(window).outerHeight() / 2 - $tip.outerHeight() / 2)

    _replaceArrow: ($tip, delta, dimension, position)->
      $tip.find('.arrow').css position, if delta then 50 * (1 - delta / dimension) + '%' else ''

    _scrollIntoView: (element, callback) ->
      $element = $(element)
      return callback() unless $element.length

      $window = $(window)
      offsetTop = $element.offset().top
      windowHeight = $window.height()
      scrollTop = Math.max(0, offsetTop - (windowHeight / 2))

      @_debug "Scroll into view. ScrollTop: #{scrollTop}. Element offset: #{offsetTop}. Window height: #{windowHeight}."
      counter = 0
      $('body, html').stop(true, true).animate
        scrollTop: Math.ceil(scrollTop),
        =>
          if ++counter is 2
            callback()
            @_debug """Scroll into view.
            Animation end element offset: #{$element.offset().top}.
            Window height: #{$window.height()}."""

    _onResize: (callback, timeout) ->
      $(window).on "resize.tour-#{@_options.name}", ->
        clearTimeout(timeout)
        timeout = setTimeout(callback, 100)

    _initMouseNavigation: ->
      _this = @

      $(document)
      .off("click.tour-#{@_options.name}", ".popover.tour-#{@_options.name} *[data-role='prev']")
      .off("click.tour-#{@_options.name}", ".popover.tour-#{@_options.name} *[data-role='next']")
      .off("click.tour-#{@_options.name}", ".popover.tour-#{@_options.name} *[data-role='end']")
      .off("click.tour-#{@_options.name}", ".popover.tour-#{@_options.name} *[data-role='pause-resume']")
      .on "click.tour-#{@_options.name}", ".popover.tour-#{@_options.name} *[data-role='next']", (e) =>
        e.preventDefault()
        @next()
      .on "click.tour-#{@_options.name}", ".popover.tour-#{@_options.name} *[data-role='prev']", (e) =>
        e.preventDefault()
        @prev()
      .on "click.tour-#{@_options.name}", ".popover.tour-#{@_options.name} *[data-role='end']", (e) =>
        e.preventDefault()
        @end()
      .on "click.tour-#{@_options.name}", ".popover.tour-#{@_options.name} *[data-role='pause-resume']", (e) ->
        e.preventDefault()
        $this = $ @

        $this.text if _this._paused then $this.data 'pause-text' else $this.data 'resume-text'
        if _this._paused then _this.resume() else _this.pause()

    _initKeyboardNavigation: ->
      return unless @_options.keyboard

      $(document).on "keyup.tour-#{@_options.name}", (e) =>
        return unless e.which

        switch e.which
          when 39
            e.preventDefault()
            if @_isLast() then @next() else @end()
          when 37
            e.preventDefault()
            @prev() if @_current > 0
          when 27
            e.preventDefault()
            @end()

    _makePromise: (result) ->
      if result and $.isFunction(result.then) then result else null

    _callOnPromiseDone: (promise, cb, arg) ->
      if promise
        promise.then (e) =>
          cb.call(@, arg)
      else
        cb.call(@, arg)

    _showBackdrop: (element) ->
      return if @backdrop.backgroundShown

      @backdrop = $ '<div>', class: 'tour-backdrop'
      @backdrop.backgroundShown = true
      $('body').append @backdrop

    _hideBackdrop: ->
      @_hideOverlayElement()
      @_hideBackground()

    _hideBackground: ->
      if @backdrop
        @backdrop.remove()
        @backdrop.overlay = null
        @backdrop.backgroundShown = false

    _showOverlayElement: (step) ->
      $element = $ step.element

      return if not $element or $element.length is 0 or @backdrop.overlayElementShown

      @backdrop.overlayElementShown = true
      @backdrop.$element = $element.addClass 'tour-step-backdrop'
      @backdrop.$background = $ '<div>', class: 'tour-step-background'
      elementData =
        width: $element.innerWidth()
        height: $element.innerHeight()
        offset: $element.offset()

      @backdrop.$background.appendTo('body')

      elementData = @_applyBackdropPadding step.backdropPadding, elementData if step.backdropPadding
      @backdrop
      .$background
      .width(elementData.width)
      .height(elementData.height)
      .offset(elementData.offset)

    _hideOverlayElement: ->
      return unless @backdrop.overlayElementShown

      @backdrop.$element.removeClass 'tour-step-backdrop'
      @backdrop.$background.remove()
      @backdrop.$element = null
      @backdrop.$background = null
      @backdrop.overlayElementShown = false

    _applyBackdropPadding: (padding, data) ->
      if typeof padding is 'object'
        padding.top ?= 0
        padding.right ?= 0
        padding.bottom ?= 0
        padding.left ?= 0

        data.offset.top = data.offset.top - padding.top
        data.offset.left = data.offset.left - padding.left
        data.width = data.width + padding.left + padding.right
        data.height = data.height + padding.top + padding.bottom
      else
        data.offset.top = data.offset.top - padding
        data.offset.left = data.offset.left - padding
        data.width = data.width + (padding * 2)
        data.height = data.height + (padding * 2)

      data

    _clearTimer: ->
      window.clearTimeout @_timer
      @_timer = null
      @_duration = null
