###
Copyright (C) 2011-2013 Typesafe, Inc <http://typesafe.com>
###

# Usage: new Chart(canvas, generalChartContraints, ...(any other component)...)
# The order of arguments is the order of drawing on the canvas.
# you can have more than one constraints.

define ->
  class Chart
    @mousemoveEventRegistered: false

    # Callback to map data sent to update method
    @updateCallback: undefined

    @currentMinutes: undefined

    constructor: (@canvas, @constraints) ->
      # Components which requires data
      @datasComp = []
      # Named components
      @components = {}
      # Components with mouse move events
      @mouseMoveComps = []
      @args = []
      if arguments.length-1 > 1
        @add(arguments[c]) for c in [2..arguments.length-1]

      # Add reference of this object to the canvas element
      $(@canvas.ctx.canvas).data("obj", @) if @canvas

    destroy: ->
      @canvas.destroy()
      @

    add: (comp, name = null) ->
      comp.withConstraints(@constraints) if not comp.constraints
      comp.chart = @
      # Named components
      if name then @components[name] = comp

      # Data points components
      @datasComp.push(comp) if comp.setPoints
      @args.push comp
      # Drawable components
      @canvas.draws.push(comp) if @canvas and comp.draw
      @

    remove: (comp) ->
      if @canvas and @canvas.draws?
        @canvas.draws = @canvas.draws.filter (c) -> comp != c

    setConstraints: (@constraints) ->
      @

    removeAll: ->
      @remove(c) for c in @args
      @args = []
      @datasComp = []

    replace: (otherChart) ->
      @removeAll()
      @setConstraints(otherChart.constraints)
      @add(c) for c in otherChart.args
      @bindMouseMove(otherChart.mouseMoveComp) if otherChart.mouseMoveComp
      @refresh()

    start: ->
      if @canvas
          @canvas.start()
          @

    stop: ->
      if @canvas
          @canvas.stop()
          @

    refresh: ->
      if @canvas
          @canvas.needRefresh = true

    update: (data) ->
      # Transform update data with callback if set
      if @updateCallback
        data = @updateCallback data

      # Update each named component
      for comp, compData of data
        if comp of @components
          @components[comp].setData compData.data if compData.data? and @components[comp].setData
          @components[comp].setValue compData.value if compData.value? and @components[comp].setValue
          @components[comp].setXUnit compData.xUnit if compData.xUnit? and @components[comp].setXUnit
          @components[comp].setY compData.y if compData.y? and @components[comp].setY
          @components[comp].setBoundaries compData.boundaries if compData.boundaries? and @components[comp].setBoundaries
          @components[comp].setUrl compData.url if compData.url? and @components[comp].setUrl
          @components[comp].setColor compData.color if compData.color? and @components[comp].setColor
          @components[comp].setHoverText compData.hoverText if compData.hoverText? and @components[comp].setHoverText
      @

    onTimeUpdateMinutes: (time) ->
      @currentMinutes = time
      # Update each named component
      for comp of @components
        @components[comp].onTimeUpdateMinutes time if @components[comp].onTimeUpdateMinutes

    bindUpdate: (callback) ->
      @updateCallback = callback
      @

    bindMouseMove: (comp, onCallback, offCallback) ->
      if @canvas
        # Add component to list
        if comp not in @mouseMoveComps
          @mouseMoveComps.push comp
        # Register callbacks
        comp.hoverOn onCallback
        comp.hoverOff offCallback
        # Add event listener to canvas if not already added
        if !@mousemoveEventRegistered
          $(@canvas.ctx.canvas).on('mousemove', (e) =>
            if @canvas.node[0] == e.target
              # Find canvas position
              offset = @canvas.node.offset()
              pos =
                x: e.clientX - offset.left
                y: e.clientY - offset.top
              # Find current component
              for mousemoveComp in @mouseMoveComps when mousemoveComp.isHover(pos.x, pos.y)
                mousemoveComp.setHover pos, e
          )
          .on('mouseout', (e) =>
            for mousemoveComp in @mouseMoveComps
              mousemoveComp.setHover null
          )
          @mousemoveEventRegistered = true
      @

  Chart