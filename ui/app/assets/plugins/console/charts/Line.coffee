###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###

# Refactoring charts
define ['console/charts/Graph', 'console/charts/ChartConfig'], (Graph, ChartConfig) ->
  class Line extends Graph
    constructor: (settings) ->
      super($.extend({
        lineColor: "rgba(255, 255, 255, 0.8)"
        shadowColor: null
        shadowBlur: 0
        animated: false
      }, settings, { fill: null }))

    setY: (y) ->
      y = @getY(y)
      @setPoints([[0,y], [1,y]])

  Line
