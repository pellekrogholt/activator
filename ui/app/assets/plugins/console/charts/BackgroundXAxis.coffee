###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ['console/charts/ChartComponent', 'console/charts/ChartConfig'], (ChartComponent, ChartConfig) ->
  class BackgroundXAxis extends ChartComponent
    constructor: (settings) ->
      @settings = $.extend({
        graphPad:
          top: 0
          bottom: 0
          left: 0
          right: 0
        bgColor: ChartConfig.colors.background
        axisBgColor: ChartConfig.colors.background
      }, settings)

    draw: (c) ->
      graphPad = @constraints.getGraphPad()
      # draw background
      yBottomGraph = c.canvas.height-graphPad.bottom # the y of the bottom of the graph = the x axis line
      w = c.canvas.width
      c.fillStyle = @settings.bgColor
      c.fillRect 0, 0, w, yBottomGraph
      c.fillStyle = @settings.axisBgColor
      c.fillRect 0, yBottomGraph, w, graphPad.bottom

    BackgroundXAxis
