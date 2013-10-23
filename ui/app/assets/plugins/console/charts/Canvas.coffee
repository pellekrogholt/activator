###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###

# Create a new canvas and append it to container (given in settings)
define ->
  class Canvas
    constructor: (settings) ->
      throw "settings.container required!" if !settings.container
      @settings = $.extend({
        animationDuration: 1500,
        id: "canvas_" + uuid(),
        class: false,
        width: $(settings.container).width(),
        height: $(settings.container).height(),
        updateOnResize: !(settings.width || settings.height),
        absolute: false
      }, settings)
      @resizeHandler = undefined
      @node = $("<canvas />").attr
                  id: @settings.id
                  width:  @settings.width
                  height: @settings.height
      if (@settings.absolute)
        @node.css
          position: "absolute"
          bottom: 0
          left: 0
          overflow: "hidden"
      if (@settings.class)
        @node.addClass @settings.class

      if @settings.updateOnResize
        @resizeHandler = => @resize()
        $(window).resize @resizeHandler
        setTimeout (@resizeHandler), 500

      @node.appendTo @settings.container
      @ctx = @node[0].getContext "2d"
      @draws = @settings.draws || []

    destroy: ->
      # Unbind resize handler from window object
      $(window).unbind('resize', @resizeHandler) if @resizeHandler
      @

    resize: ->
      if @settings.updateOnResize
        w = $(@settings.container).width()
        h = $(@settings.container).height()
        if w isnt @ctx.canvas.width or h isnt @ctx.canvas.height
          @ctx.canvas.width = w
          @ctx.canvas.height = h
          @needRefresh = true

    start: ->
      return if @running
      @startTime = +new Date()
      @running = true
      @needRefresh = true
      @_loop()

    stop: ->
      @running = false

    _loop: ->
      return if not @running
      requestAnimFrame((=> @_loop()), @node[0])

      # check if one component need the refresh
      oneComponentNeedRefresh = false
      for d in @draws
        if(d.needRefresh && d.needRefresh())
          oneComponentNeedRefresh = true
      if oneComponentNeedRefresh
        @needRefresh = true

      return if !@needRefresh

      # compute the starting animation progress
      progress = Math.min(1, (+new Date() - @startTime) / @settings.animationDuration)

      # draw components on the canvas
      c = @ctx
      c.clearRect 0, 0, c.canvas.width, c.canvas.height

      for d in @draws
        c.save()
        d.transform && d.transform(c)
        d.draw(c, progress)
        c.restore()

      # stop the refresh need if the progress has reached the end
      if !oneComponentNeedRefresh and progress is 1
        @needRefresh = false

  Canvas
