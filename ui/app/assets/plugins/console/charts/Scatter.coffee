###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ['console/charts/ChartComponent', 'console/charts/ChartConfig'], (ChartComponent, ChartConfig) ->
  class Scatter extends ChartComponent

    sampledColors: ['#53EC50','#54EC50','#55EC51','#56EC51','#57EC52','#58EC53','#59EC53','#5AEC54','#5BEC54','#5CEC55','#5DEC56','#5EEC56','#5FEC57','#60EC58','#61EC58','#62EC59','#63EC59','#64EC5A','#65EC5B','#66EC5B','#67EC5C','#68EC5D','#69EC5D','#6AEC5E','#6BEC5E','#6CEC5F','#6DEC60','#6EEC60','#6FEC61','#70EC62','#71EC62','#72EC63','#73EC63','#74EC64','#75EC65','#76EC65','#77EC66','#78EC67','#79EC67','#7AEC68','#7BEC68','#7DEC69','#7EEC6A','#7FEC6A','#80EC6B','#81EC6C','#82EC6C','#83EC6D','#84EC6D','#85EC6E','#86EC6F','#87EC6F','#88EC70','#89EC71','#8AEC71','#8BEC72','#8CEC72','#8DEC73','#8EEC74','#8FEC74','#90EC75','#91EC76','#92EC76','#93EC77','#94EC77','#95EC78','#96EC79','#97EC79','#98EC7A','#99EC7B','#9AEC7B','#9BEC7C','#9CEC7C','#9DEC7D','#9EEC7E','#9FEC7E','#A0EC7F','#A1EC80','#A2EC80','#A3EC81','#A4EC81','#A6ED82','#A7ED83','#A8ED83','#A9ED84','#AAED84','#ABED85','#ACED86','#ADED86','#AEED87','#AFED88','#B0ED88','#B1ED89','#B2ED89','#B3ED8A','#B4ED8B','#B5ED8B','#B6ED8C','#B7ED8D','#B8ED8D','#B9ED8E','#BAED8E','#BBED8F','#BCED90','#BDED90','#BEED91','#BFED92','#C0ED92','#C1ED93','#C2ED93','#C3ED94','#C4ED95','#C5ED95','#C6ED96','#C7ED97','#C8ED97','#C9ED98','#CAED98','#CBED99','#CCED9A','#CDED9A','#CEED9B','#D0ED9C','#D1ED9C','#D2ED9D','#D3ED9D','#D4ED9E','#D5ED9F','#D6ED9F','#D7EDA0','#D8EDA1','#D9EDA1','#DAEDA2','#DBEDA2','#DCEDA3','#DDEDA4','#DEEDA4','#DFEDA5','#E0EDA6','#E1EDA6','#E2EDA7','#E3EDA7','#E4EDA8','#E5EDA9','#E6EDA9','#E7EDAA','#E8EDAB','#E9EDAB','#EAEDAC','#EBEDAC','#ECEDAD','#EDEDAE','#EEEDAE','#EFEDAF','#F0EDB0','#F1EDB0','#F2EDB1','#F3EDB1','#F4EDB2','#F5EDB3','#F6EDB3','#F7EDB4','#F9EEB5']

    constructor: (settings) ->
      @settings = $.extend({
        bgColor: ChartConfig.colors.background
        dotColor: ChartConfig.colors.mainBlue
        pushConstraints: true
        font: ChartConfig.fonts.standard
        animated: true
        withHover: false
        smooth: 3
        maxSampled: 1000
        hoverOn: undefined
        hoverOff: undefined
      }, settings)

    # points is an array of vector.
    # A vector is a [x, y, sampled] where x is in [0,1] and y in [0,1]
    points: []
    setPoints: (@points) ->
      @chart.refresh()

    hoverOn: (callback) ->
      @settings.hoverOn = callback
      @

    hoverOff: (callback) ->
      @settings.hoverOff = callback
      @

    setHover: (@hoverPosition, e) ->
      noHover = false
      if @hoverPosition
        pad = @constraints.getGraphPad()
        boundY = @constraints.getBoundY()
        x = @hoverPosition.x - pad.left
        @hoverPoint = @getDataPointForX(1-x/@w)
        if @hoverPoint and @hoverPoint[1] isnt undefined
          t = new Date(@hoverPoint[0])
          time = format.formatDate(t) + ' ' + format.formatTime(t)

          hoverPopup.
            text(time).
            position(e.clientX, e.clientY).
            show()
        else
          noHover = true
      else
        noHover = true

      if noHover and @hoverPoint isnt null
        @hoverPoint = null
        hoverPopup.hide()

    isHover: (x, y) ->
      true

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
      t = []
      t.push [@getX(d[0]), @getY(d[1]), d[2]] for d in data
      @setPoints t

    onTimeUpdateMinutes: (time) ->
      @constraints.extendSettings
        xMax : time
        xStep : calcTimeSteps time

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
      c.strokeStyle = @settings.bgColor if @settings.bgColor
      c.rect(0, 0, @w, @h)
      c.clip()

    needRefresh: ->
      @hoverPoint isnt @lastHoverPointDraw

    draw: (c, p) ->
      return if(@points.length==0)
      hoverPoint = @lastHoverPointDraw = @hoverPoint
      lastWidth = p*@w
      lastHeight = @h

      # Draw the scatter plot
      if lastWidth > @w*@points[0][0]
        # It would be more efficient to use canvas image data, but fillRect is a good start
        # http://stackoverflow.com/questions/7812514/drawing-a-dot-on-html5-canvas
        # c.beginPath()
        c.shadowBlur = 0
        maxSampled = @settings.maxSampled
        foundSampled = 0

        for vector in @points
          w = @w*vector[0]
          lastHeight = @h*vector[1]
          break if @settings.animated && w>lastWidth
          if vector[2]?
            sampled = Math.min(vector[2], maxSampled)
            sampledColorsIndex = Math.floor((@sampledColors.length - 1) * sampled / maxSampled)
            sampledColor = @sampledColors[sampledColorsIndex]
            c.fillStyle = sampledColor
            if sampled > foundSampled
              foundSampled = sampled
              foundSampledColor = sampledColor
          else
            c.fillStyle = @settings.dotColor
          c.fillRect(w, lastHeight, 1, 1)

        if foundSampled > 0
          c.font = @settings.font
          c.fillStyle = foundSampledColor
          c.fillText "sampled: " + foundSampled, 30, 12

        c.stroke()



      # Drawing a drawer circle
      if @settings.animated && p<1
        c.fillStyle = @settings.dotColor
        c.globalCompositionOperation = 'lighter'
        c.shadowColor = @settings.dotColor
        c.shadowBlur = 4
        r = 2
        x = lastWidth
        y = lastHeight
        c.beginPath()
        c.arc(x, y, r, 0, Math.PI*2, false)
        c.fill()

      else if hoverPoint
        c.fillStyle = @settings.dotColor
        c.globalCompositionOperation = 'lighter'
        x = @w*@getX(hoverPoint[0])
        c.beginPath()
        c.shadowBlur = 0
        c.globalAlpha = 0.2
        c.fillRect(x, 0, 1, @h)

  Scatter
