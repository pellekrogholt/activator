###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ['console/charts/ChartComponent', 'console/charts/ChartConfig'], (ChartComponent, ChartConfig) ->
  class Histogram extends ChartComponent
      constructor: (settings) ->
          @settings = $.extend({
          number: 10 # total number of bars, we will take the last {number} value of given data
          bgColor: false
          color: ChartConfig.colors.mainYellow
          boundaries: []
          pushConstraints: true
          hoverOn: undefined
          hoverOff: undefined
          }, settings)

      # values of the bars is an array of value bounded to [0, 1]
      setValues: (@values) ->
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
              i = Math.round(@settings.number*x/@w)
              if (@data && @data.length+1>@settings.number)
                  i += @data.length-@settings.number-1
              @hoverIndex = i
              if @data isnt undefined and @data[i] isnt undefined
                  if i == 0
                    interval = '0 - ' + @settings.boundaries[0]
                  else if i == @settings.boundaries.length
                    interval = ' > ' + @settings.boundaries[i-1]
                  else
                    interval = '' + @settings.boundaries[i-1] + ' - ' + @settings.boundaries[i]

                  hoverPopup.
                  text(''+@data[i] + ' [' + interval + '] ' + String.fromCharCode(0xB5) + 's').
                  position(e.clientX, e.clientY).
                  show()
              else
                  noHover = true
          else
              noHover = true

          if noHover and @hoverIndex isnt undefined
              @hoverIndex = undefined
              hoverPopup.hide()

      # unbounded array of data values
      setData: (@data) ->
          if @settings.pushConstraints
              minY = 0
              maxY = @getMaxY()
              stepY = findNiceRoundScale(minY, maxY, 4)
              @constraints.extendSettings
                  yMax: maxY
                  yMin: minY
                  yStep: stepY
          t = []
          t.push(if(d is undefined) then undefined else @getY(d)) for d in @data
          @setValues t

      setBoundaries: (boundaries) ->
        @settings.boundaries = boundaries
        @settings.number = boundaries.length + 1
        @constraints.extendSettings
          xMax : boundaries.length + 1
          xStep : boundaries.length + 1
        @

      getY: (value) ->
          yBound = @constraints.getBoundY()
          1 - (value / yBound.max)

      xToRealX: (x, w, xBound) ->
          w*((xBound.max-x)/(xBound.max-xBound.min))

      getMaxY: () ->
          findNiceYMax(@data, 1, 1.3)

      transform: (c) ->
          pad = @constraints.getGraphPad()
          c.translate(pad.left, pad.top)
          @w = c.canvas.width-pad.left-pad.right
          @h = c.canvas.height-pad.bottom-pad.top

      needRefresh: ->
          @hoverIndex isnt @lastHoverPointDraw

      draw: (c, p) ->
          return if !@values

          hoverIndex = @lastHoverPointDraw = @hoverIndex
          xBound = @constraints.getBoundX()
          tab = @values
          dx = (xBound.max-xBound.min)/@settings.number # dx between each bar
          dxReal = Math.abs(@xToRealX(1, @w, xBound)-@xToRealX(1+dx, @w, xBound))
          barW = Math.floor(dxReal) - 1

          p = EasingFunctions.easeOutQuad(p)

          # starting from right to left
          x = 0
          for i in [tab.length..tab.length-@settings.number] when tab[i] isnt undefined
              realX = Math.floor(@xToRealX(x, @w, xBound)-barW)
              progress = Math.max(0, Math.min( 2*p-(i+1)/@settings.number, 1))
              realY = tab[i] * @h + (1-progress)*(1-tab[i])*@h
              if @settings.bgColor
                  c.fillStyle = @settings.bgColor
                  c.fillRect realX, 0, barW, realY - 4
              c.fillStyle = @settings.color
              c.fillRect realX, realY, barW, @h-realY
              if i is hoverIndex
                  c.save()
                  c.fillStyle = 'rgba(255,255,255,0.5)'
                  c.globalCompositionOperation = 'lighter'
                  c.fillRect realX, realY, barW, @h-realY
                  c.restore()
              x += dx

  Histogram
