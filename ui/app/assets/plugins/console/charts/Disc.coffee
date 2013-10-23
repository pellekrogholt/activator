###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ['console/charts/ChartComponent'], (ChartComponent) ->
  class Disc extends ChartComponent
      constructor: (settings) ->
          @settings = $.extend({
              radius: 10
              color: 'rgb(30,30,30)'
              shadow: null,
              shrinkFrom: 0
          }, settings)

      transform: (c) ->
          pad = @constraints.getGraphPad()
          center = Math.floor(Math.min(c.canvas.width, c.canvas.height)/2)
          c.translate(pad.left+center, pad.top+center)

      draw: (c, p) ->
          # compute serrated angle
          c.fillStyle = @settings.color
          if @settings.shadow
              shadow = @settings.shadow
              c.shadowColor = shadow.color || 'white'
              c.shadowBlur = shadow.blur || 1
              c.shadowOffsetX = shadow.x || 0
              c.shadowOffsetY = shadow.y || 0
          c.beginPath()
          rad = if @settings.shrinkFrom > 0 then @settings.shrinkFrom * (1-p) + 1 else 1
          c.arc(0, 0, @settings.radius * rad, 0, Math.PI*2, false)
          c.fill()

  Disc
