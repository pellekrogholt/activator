###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ['console/charts/ChartComponent', 'console/charts/ChartConfig'], (ChartComponent, ChartConfig) ->
  class Ring extends ChartComponent
    constructor: (settings) ->
      @settings = $.extend({
        radius: 20 # external radius
        width: 10 # ring width
        max: 1 # the max value
        serrated: 0 # the number of "split" in the ring (TODO)
        animationDuration: ChartConfig.animation.duration
        padding: 0
        color: ChartConfig.colors.line
        colorSwitches: {}
        bgColor: ChartConfig.colors.background
        paddingColor: ChartConfig.colors.background
        highlightLighter: 'rgba(255, 255, 255, 0.1)'
        highlightDarker: 'rgba(0, 0, 0, 0.05)'
        hoverText: undefined
        hoverOn: undefined
        hoverOff: undefined
      }, settings)
      @settings.colorSwitches.default = @settings.color

    setValue: (value) ->
      @old = @value
      @valueDate = +new Date()
      @value = Math.min(@settings.max, Math.max(0, value))
      @chart.refresh()

    valueDate: +new Date()
    value: 1
    old: 1

    isAnimating: -> +new Date() <= @valueDate + @settings.animationDuration
    getAnimationProgress: -> Math.min(1, (+new Date() - @valueDate)/@settings.animationDuration)
    needRefresh: ->
      if @highlighted_hasChanged
        @highlighted_hasChanged = false
        return true
      @isAnimating()

    setColor: (color) ->
      color = 'default' if !color
      if @settings.colorSwitches[color]
        @settings.color = @settings.colorSwitches[color]
      else
        @settings.color = color

    setHighlighted: (@highlighted) ->
      @highlighted_hasChanged = true

    setHoverText: (text) ->
      @settings.hoverText = text
      @

    hoverOn: (callback) ->
      @settings.hoverOn = callback
      @

    hoverOff: (callback) ->
      @settings.hoverOff = callback
      @

    setHover: (@hoverPosition, e) ->
      if @hoverPosition
        if @settings.hoverText and @isHover @hoverPosition.x, @hoverPosition.y
          @settings.hoverOn @settings.hoverText, {x: e.clientX, y: e.clientY}, @
      else
        @settings.hoverOff @

    # return true is the position (x, y) is in the ring.
    isHover: (x, y) ->
      pad = @constraints.getGraphPad()
      x -= pad.left+@center
      y -= pad.top+@center
      hyp2 = x*x + y*y
      max2 = @settings.radius
      max2 *= max2
      min2 = @settings.radius - @settings.width
      min2 *= min2
      (min2 < hyp2 and hyp2 < max2)

    transform: (c) ->
      pad = @constraints.getGraphPad()
      @center = Math.floor(Math.min(c.canvas.width, c.canvas.height)/2)
      c.translate(pad.left+@center, pad.top+@center)

    draw: (c, startProgress) ->
      p = @getAnimationProgress()
      p = EasingFunctions.easeOutQuad(p)
      value = @value*p + (1-p)*@old

      # compute serrated angle
      valueAngle = (value/@settings.max)*2*Math.PI
      fromAngle = 0 - Math.PI/2
      toAngle = valueAngle - Math.PI/2
      ringWidth = @settings.width
      r = @settings.radius - ringWidth / 2

      c.lineWidth = ringWidth
      c.strokeStyle = @settings.bgColor
      c.beginPath()
      c.arc(0, 0, r, 0, 2*Math.PI, false)
      c.stroke()

      if @settings.padding
        c.lineWidth = ringWidth
        c.strokeStyle = @settings.paddingColor
        c.beginPath()
        c.arc(0, 0, r, fromAngle, toAngle, false)
        c.stroke()
        ringWidth -= 2*@settings.padding

      c.lineWidth = ringWidth
      c.strokeStyle = @settings.color
      c.beginPath()
      c.arc(0, 0, r, fromAngle, toAngle, false)
      c.stroke()

      if @highlighted
        if @settings.padding
          ringWidth += 2*@settings.padding
        c.lineWidth = ringWidth
        c.strokeStyle = @settings.highlightDarker
        c.globalCompositeOperation = 'darker'
        c.beginPath()
        c.arc(0, 0, r, 0, 2*Math.PI, false)
        c.stroke()

        c.strokeStyle = @settings.highlightLighter
        c.globalCompositeOperation = 'lighter'
        c.beginPath()
        c.arc(0, 0, r, fromAngle, toAngle, false)
        c.stroke()

  Ring
