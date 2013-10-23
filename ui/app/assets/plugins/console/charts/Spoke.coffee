###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ['console/charts/ChartComponent'], (ChartComponent) ->
  class Spoke extends ChartComponent
      lengthOffset: []
      angleOffset: []
      startOffset: 0

      constructor: (settings) ->
          @value = 0
          @settings = $.extend({
              radius: 10
              color: 'rgb(30,30,30)'
              max: 100
              pointColor: 'rgb(40,40,40)'
              activeColor: 'rgb(80, 130, 155)'
              pointSize: 2
              innerRadius: 0
          }, settings)

      setValue: (value, @active) ->
          @old = @value
          @valueDate = +new Date()
          @value = Math.min(@settings.max, Math.max(0, value))

          if @value != @old
              # Offset the spokes a bit, to look nice
              for i in [1.. value]
                  @lengthOffset.push(~~(Math.random() * 10) - 5)
                  @angleOffset.push((~~(Math.random() * 6) + 3) * (Math.PI / 180))
                  @startOffset = ~~(Math.random() * 360) * (Math.PI / 180)

          @chart.refresh()

      transform: (c) ->
        pad = @constraints.getGraphPad()
        center = Math.floor(Math.min(c.canvas.width, c.canvas.height)/2)
        c.translate(pad.left+center, pad.top+center)

      draw: (c, p) ->
          radius = @settings.radius

          # dashes
          c.strokeStyle = @settings.activeColor
          c.fillStyle = @settings.pointColor

          drawValue = if @value > 200 then 200 else @value

          segs = 360 / drawValue
          rads = segs * Math.PI / 180

          cur = @startOffset
          indx = 0

          p = EasingFunctions.easeOutQuad(p)

          while indx < drawValue
              if indx >= @active
                  c.strokeStyle = @settings.color
              cur += rads

              # Get offsets for making things "uneven"
              lenOff = (@lengthOffset[indx] * p)
              angOff = (@angleOffset[indx] * p) - Math.PI

              # Draw the spoke line
              c.lineWidth = 1
              c.beginPath()
              sinX = Math.sin(cur - Math.PI - angOff) # -Math.PI just to offset it a lil'
              cosY = Math.cos(cur - Math.PI - angOff)
              c.moveTo(sinX * @settings.innerRadius, cosY * @settings.innerRadius)

              x = sinX * ((radius + lenOff) * p)
              y = cosY * ((radius + lenOff) * p)
              c.lineTo x, y
              c.stroke()

              # Draw the spoke circle
              c.lineWidth = 2
              c.beginPath()
              c.arc(x, y, @settings.pointSize, 0, Math.PI*2, false)
              c.fill()
              c.stroke()

              indx++

  Spoke
