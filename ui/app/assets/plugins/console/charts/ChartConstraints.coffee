###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###
define ->
  class ChartConstraints
    constructor: (settings) ->
      @extendSettings(settings)

    extendSettings: (settings) ->
      @settings = $.extend({
        xMin: 0
        xMax: 15
        xStep: 5
        xUnit: ''
        xUnitScaleThreshold: 0
        yMin: 0
        yMax: 5
        yStep: 1
        yUnit: ''
        graphPad:
          top: 0
          right: 0
          bottom: 0
          left: 0
      }, window.GRID_PARAMS, @settings, settings)

    getBoundX: () ->
      xBounds =
        min: @settings.xMin
        max: @settings.xMax
        step: @settings.xStep
        unit: @settings.xUnit
        scale: 1
      # Scale x axis unit if needed
      if @settings.xUnitScaleThreshold > 0
        xBounds.scale = 1
        # Days
        if xBounds.max / 1440 >= @settings.xUnitScaleThreshold
          xBounds.scale = 1/1440
          xBounds.unit = 'd'
        # Hours
        else if xBounds.max / 60 >= @settings.xUnitScaleThreshold
          xBounds.scale = 1/60
          xBounds.unit = 'h'
        if xBounds.scale != 1
          xBounds.min = xBounds.min * xBounds.scale
          xBounds.max = xBounds.max * xBounds.scale
          xBounds.step = Math.max Math.floor(xBounds.step * xBounds.scale), 1

      xBounds

    getBoundY: () ->
      min: @settings.yMin
      max: @settings.yMax
      step: @settings.yStep
      unit: @settings.yUnit

    getGraphPad: () ->
      @settings.graphPad

    getTimeWindow: () -> @settings.xMax * 60 * 1000

  ChartConstraints
