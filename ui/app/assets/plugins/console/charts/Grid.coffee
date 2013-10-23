###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ['console/charts/ChartComponent', 'console/charts/ChartConfig'], (ChartComponent, ChartConfig) ->
  class Grid extends ChartComponent
    constructor: (settings) ->
      @settings = $.extend({
        xUnit: null # for overriding chart constraints
        yUnit: null # for overriding chart constraints
        textPad:
          x: 2
          y: 0
        largeTextPad:
          x: 2
          y: -2
        gridColor: ChartConfig.colors.grid
        axisLineColor: ChartConfig.colors.grid
        xAxisNumberColor: ChartConfig.colors.gridText
        yAxisNumberColor: ChartConfig.colors.gridText
        yAxisRight: false
        yAxisRightPadding: 25
        font: ChartConfig.fonts.standard
        largeFont: ChartConfig.fonts.large
        largePadding: 30
        drawX: true
        histogram: undefined
        drawY: true
        drawGrid: true
        drawTexts: true
        useMinus: true
        timestamp: false
        debug: false
      }, settings)

      @isLarge = false

    setXUnit: (unit) ->
      $.extend(@settings, {
        xUnit : unit
      }, @settings)
      @

    xToRealX: (x, w) ->
      graphPad = @constraints.getGraphPad()
      if @settings.isLarge
        graphPad.left = @settings.largePadding

      xBound = @constraints.getBoundX()
      dx = xBound.max - xBound.min
      x = (dx-x)/dx
      x = graphPad.left+x*(w-graphPad.left-graphPad.right)
      Math.floor(x)

    yToRealY: (y, h) ->
      graphPad = @constraints.getGraphPad()
      if @settings.isLarge
        graphPad.left = @settings.largePadding
      yBound = @constraints.getBoundY()
      dy = yBound.max - yBound.min
      y = (dy-y)/dy
      y = y*(h-graphPad.bottom)
      Math.floor(y)

    draw: (c) ->
      graphPad = @constraints.getGraphPad()
      xBound = @constraints.getBoundX()
      yBound = @constraints.getBoundY()
      yBottomGraph = c.canvas.height-graphPad.bottom # the y of the bottom of the graph = the x axis line
      w = c.canvas.width
      h = c.canvas.height
      if @settings.isLarge
        textPad = @settings.largeTextPad
      else
        textPad = @settings.textPad

      ySteps = []
      i = 0
      y = yBound.min
      # Rounding value must be larger for small y steps to get any y axis values at all
      yRound = if yBound.step >= 0.02 then 50 else 250
      while y <= yBound.max and i < 10
        ySteps.push(y)
        y = Math.round(yRound * (y+yBound.step)) / yRound
        ++ i

      xSteps = []
      i = 0
      x = xBound.min
      while x <= xBound.max and i < 10
        xSteps.push(x)
        x += xBound.step
        ++ i

      # draw x axis
      if @settings.drawX
        c.fillStyle = @settings.axisLineColor
        c.fillRect 0, yBottomGraph, w, 1

      ## draw grid
      # x axis
      if @settings.drawX
        for x in xSteps
          xReal = @xToRealX(x, w)
          if xReal < w-5
            if @settings.drawGrid
              c.fillStyle = @settings.gridColor
              c.fillRect xReal, 0, 1, yBottomGraph
            c.fillStyle = @settings.axisLineColor
            c.fillRect xReal, yBottomGraph, 1, 5

      # y axis
      if @settings.drawY
        if @settings.drawGrid
          c.fillStyle = @settings.gridColor
          for y in ySteps
            yReal = @yToRealY(y, h)
            if yReal < yBottomGraph
              c.fillRect graphPad.left, yReal, w-graphPad.left, 1

      ## draw texts
      if @settings.drawTexts
        if @settings.histogram?
          @drawHistogramXAxisText c, textPad, w
        else if @settings.drawX
          @drawXAxisText c, textPad, xSteps, w, xBound

        if @settings.drawY
          # y axis
          c.fillStyle = @settings.yAxisNumberColor
          if @settings.yAxisRight
            padding = @settings.yAxisRightPadding
            c.textAlign = "left"
            x = w+textPad.x - padding
            textX = w-textPad.x - padding
          else
            c.textAlign = "right"
            x = graphPad.left-textPad.x
            textX = graphPad.left+textPad.x

          c.textBaseline = "middle"

          # If the Y steps are > 1000 we need to convert down
          binaryLetters = ["", "k", "M", "G", "T", "P", "E"]
          binaryLetter = ""
          binaryPow = 0
          if yBound.step > 100
              exp = yBound.step.toExponential(10).split("e")
              pow10 = parseInt(exp[1])
              binaryPow = Math.max(0, Math.min(binaryLetters.length-1, Math.floor((pow10 + 1) / 3)))
              binaryLetter = binaryLetters[binaryPow]

          for y in ySteps
            yReal = @yToRealY(y, h)
            if 5 < yReal and yReal <= yBottomGraph-5
              # Scale y if binary power > 0
              y = y / Math.pow(10, binaryPow * 3) if binaryPow > 0
              c.fillText y, x, yReal

          c.textAlign = if @settings.yAxisRight then "right" else "left"
          c.textBaseline = "top"

          # Final unit adjustment to avoid "k µs" etc
          unit = yBound.unit
          if binaryPow > 0
              switch unit
                  when (String.fromCharCode(0xB5) + "s")
                      if binaryPow == 1
                          binaryPow = 0
                          unit = "ms"
                      else
                          binaryPow -= 2
                          unit = "s"
                  when "ms"
                      binaryPower -= 2
                      unit = "s"
              binaryLetter = binaryLetters[binaryPow]
          unit = if binaryLetter != "" then binaryLetter + " " + unit else unit
          c.fillText unit, textX, textPad.y

    drawHistogramXAxisText: (c, textPad, w) ->
      if @settings.isLarge
        c.font = @settings.largeFont
      else
        c.font = @settings.font
      c.fillStyle = @settings.xAxisNumberColor
      c.textAlign = "right"
      c.textBaseline = "bottom"
      bottom = c.canvas.height - textPad.y

      c.fillText @settings.xUnit, w-textPad.x, bottom

      c.textAlign = "center"
      stepper = 2
      useSmartStepping = true
      boundaries = @settings.histogram.settings.boundaries
      cnt = boundaries.length
      if boundaries.length > 10
        c.fillText "0", @xToRealX(cnt + 1, w), bottom
        if $(window).width() < 1600
          stepper = 4
      else
        c.fillText "0", @xToRealX(cnt + 1, w), bottom
        if $(window).width() < 1350
          stepper = 2
        else
          useSmartStepping = false

      for boundary in boundaries
        if !useSmartStepping or (useSmartStepping and cnt % stepper == 0)
          xReal = @xToRealX(cnt, w)
          c.fillText boundary, xReal, bottom

        cnt--

    drawXAxisText: (c, textPad, xSteps, w, xBound) ->
      # x axis
      c.font = @settings.font
      if @settings.isLarge
        c.font = @settings.largeFont
      c.fillStyle = @settings.xAxisNumberColor
      c.textAlign = "center"
      c.textBaseline = "bottom"
      bottom = c.canvas.height - textPad.y

      cnt = 0
      for x in xSteps
        cnt++
        xReal = @xToRealX(x, w)
        if xReal < w-15
          lbl = if @settings.timestamp and cnt == xSteps.length then xBound.unit else ""
          minus = if @settings.useMinus then "-" else ""
          c.fillText minus + x + lbl, xReal, bottom
        c.textAlign = "right"

      # Draw timestamp on X if provided
      if @settings.timestamp
        c.fillText @settings.timestamp, w-textPad.x, bottom
      else
        c.fillText xBound.unit, w-textPad.x, bottom

  Grid
