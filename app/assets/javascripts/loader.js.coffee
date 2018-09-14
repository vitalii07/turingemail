###############################
### Loader Class Definition ###
###############################

(($, window, document) ->

  Loader = (container) ->
    @path_length = []
    @total_length = 0
    @container = $(container)
    @paths = @container.children()
    @init()
    return

  Loader.prototype =
    init: ->
      i = 0
      while i < @paths.length
        path = @paths[i]
        length = path.getTotalLength()
        @path_length.push length
        @total_length += length
        $(path).attr('stroke-dasharray', length).attr 'stroke-dashoffset', length
        i++
      @container.attr 'stroke', '#FFFFFF'
      return
    setProgress: (progress) ->
      grow = 0
      position = @total_length * progress
      i = 0
      while i < @paths.length
        length = @path_length[i]
        offset = length - Math.max(0, Math.min(position - grow, length))
        $(@paths[i]).attr 'stroke-dashoffset', offset
        grow += length
        i++
      return
  window.Loader = Loader
  return
) jQuery, window, document

######################
### Loader Methods ###
######################

Loader.pageContainsLoader = ->
  $("#loader-group").length > 0

Loader.progressLoaderLoop = (loader, totalTimeInterval, progressCount) ->
  setTimeout (->
    loader.setProgress progressCount / totalTimeInterval
    Loader.progressLoaderLoop(loader, totalTimeInterval, ++progressCount) if progressCount < totalTimeInterval
    return
  ), 1
  return

#######################
### Starting Loader ###
#######################

$ ->
	Loader.progressLoaderLoop(new Loader('#loader-group'), 375, 0) if Loader.pageContainsLoader()
