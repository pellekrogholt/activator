###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ['console/charts/ChartComponent', 'console/charts/ChartConfig'], (ChartComponent, ChartConfig) ->
  class Graph extends ChartComponent
    constructor: (settings) ->
      @settings = $.extend({
        fill: null
        lineWidth: ChartConfig.graph.lineWidth
        lineColor: ChartConfig.colors.line
        shadowColor: ChartConfig.colors.line
        shadowBlur: false
        pushConstraints: true
        animated: true
        withHover: false
        smooth: 3
        hoverOn: undefined
        hoverOff: undefined
      }, settings)

    # points is an array of vector.
    # A vector is a [x, y] where x is in [0,1] and y in [0,1]
    points: []
    setPoints: (@points) ->
      @chart.refresh()

    hoverOn: (callback) ->
      @settings.hoverOn = callback
      @

    hoverOff: (callback) ->
      @settings.hoverOff = callback
      @

    isHover: (x, y) ->
      true

    setHover: (@hoverPosition, e) ->
      noHover = false
      if @hoverPosition
        pad = @constraints.getGraphPad()
        boundY = @constraints.getBoundY()
        x = @hoverPosition.x - pad.left
        @hoverPoint = @getDataPointForX(1-x/@w)
        if @hoverPoint and @hoverPoint[1] isnt undefined
          v = @hoverPoint[1]
          t = new Date(@hoverPoint[0])
          time = format.formatDate(t) + ' ' + format.formatTime(t)
          if boundY.unit == (String.fromCharCode(0xB5) + "s") and v > 1000 then (v = (v / 1000).toFixed(1); boundY.unit = "ms")
          if boundY.unit == "ms" and v > 1000 then (v = (v / 1000).toFixed(2); boundY.unit = "s")
          if (@hoverPoint[1] + "").indexOf('.') > 0 then v = format.shorten(''+@hoverPoint[1])
          @settings.hoverOn (v + (if !boundY.unit then '' else (' '+boundY.unit)) + ' - ' + time), {x: e.clientX, y: e.clientY}, @
        else
          noHover = true
      else
        noHover = true

      if noHover and @hoverPoint isnt null
        @hoverPoint = null
        @settings.hoverOff()

    # x is a [0, 1] graph point, use getX() if you have a timestamp
    getDataPointForX: (x) ->
      return if not @data
      i = 0
      x = x*@constraints.getTimeWindow()
      x = @data[@data.length-1][0] - x
      while i < @data.length and @data[i][0] < x
        ++i
      if i is @data.length
        undefined
      else
        @data[i]

    setData: (data) ->
      return if data.length == 0
      @data = data

      lastTimestamp = @data[@data.length-1][0]

      @startAtTimestamp = lastTimestamp-@constraints.getTimeWindow()
      @endAtTimestamp = lastTimestamp

      if @settings.pushConstraints
        minY = 0
        maxY = @getMaxY()
        stepY = findNiceRoundScale(minY, maxY, 4)
        @constraints.extendSettings
          yMax: maxY
          yMin: minY
          yStep: stepY
      else
        @constraints.extendSettings
          yStep: findNiceRoundScale(@constraints.settings.yMin, @constraints.settings.yMax, 4)

      t = []
      previousData = [0,0]
      totalDifference = 0
      count = 0
      gapFound = false

      for d in data
        if (count > 1)
          difference = d[0] - previousData[0]
          totalDifference = totalDifference + difference
          gapFound = true if (difference > ((totalDifference / count) * 4))

        # check if there is a gap and if so add two new points in time to the data
        if gapFound == true
          t.push [@getX(previousData[0]), @getMaxY()]
          t.push [@getX(d[0] - 1), @getMaxY()]
          gapFound = false

        count = count + 1
        previousData = d
        t.push [@getX(d[0]), @getY(d[1])]


      @setPoints t

    getX: (value) ->
      (value - @startAtTimestamp) / @constraints.getTimeWindow()

    getY: (value) ->
      yBound = @constraints.getBoundY()
      1 - (value / yBound.max)

    getMaxY: () ->
      data = []
      for vector in @data
        data.push(vector[1])
      niceMax = findNiceYMax(data, @settings.smooth)
      return if niceMax == 0 then 10 else niceMax

    transform: (c) ->
      pad = @constraints.getGraphPad()
      c.translate(pad.left, pad.top)
      @w = c.canvas.width-pad.left-pad.right
      @h = c.canvas.height-pad.bottom-pad.top
      c.beginPath()
      c.rect(0, 0, @w, @h)
      c.clip()

    needRefresh: ->
      @hoverPoint isnt @lastHoverPointDraw

    onTimeUpdateMinutes: (time) ->
      @constraints.extendSettings
        xMax : time
        xStep : calcTimeSteps time

    draw: (c, p) ->
      return if(@points.length==0)
      hoverPoint = @lastHoverPointDraw = @hoverPoint
      lastWidth = p*@w
      lastHeight = @h
      c.lineWidth = @settings.lineWidth
      c.strokeStyle = @settings.lineColor
      if @settings.shadowBlur
        c.shadowColor = @settings.shadowColor || @settings.lineColor
        c.shadowBlur = @settings.shadowBlur

      # Draw the line graph
      if lastWidth > @w*@points[0][0]
        c.beginPath()
        c.moveTo(@w*@points[0][0], @h*@points[0][1])

        for vector in @points
          w = @w*vector[0]
          lastHeight = @h*vector[1]
          break if @settings.animated && w>lastWidth
          c.lineTo(w, lastHeight)
        c.lineTo(lastWidth+c.lineWidth, lastHeight)
        c.stroke()

        c.shadowBlur = 0

        if @settings.fill
          c.lineTo(lastWidth+c.lineWidth, lastHeight)
          c.lineTo(lastWidth+c.lineWidth, @h)
          c.lineTo(@w*@points[0][0], @h)
          c.fillStyle = @settings.fill
          c.fill()

      # Drawing a drawer circle
      if @settings.animated && p<1
        c.fillStyle = @settings.lineColor
        c.globalCompositionOperation = 'lighter'
        c.shadowColor = @settings.lineColor
        c.shadowBlur = 4
        r = 2
        x = lastWidth
        y = lastHeight
        c.beginPath()
        c.arc(x, y, r, 0, Math.PI*2, false)
        c.fill()

      else if hoverPoint
        c.fillStyle = @settings.lineColor
        c.globalCompositionOperation = 'lighter'
        c.shadowColor = @settings.lineColor
        c.shadowBlur = 4
        r = 3
        x = @w*@getX(hoverPoint[0])
        y = @h*@getY(hoverPoint[1])
        c.beginPath()
        c.arc(x, y, r, 0, Math.PI*2, false)
        c.fill()
        c.shadowBlur = 0
        c.globalAlpha = 0.2
        c.fillRect(x, 0, 1, @h)

  Graph
