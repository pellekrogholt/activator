define ['console/charts/ChartConfig',
        'console/charts/Chart',
        'console/charts/Canvas',
        'console/charts/ChartComponent',
        'console/charts/ChartConstraints'
        'console/charts/BackgroundXAxis'
        'console/charts/Bar'
        'console/charts/Disc'
        'console/charts/Graph'
        'console/charts/Grid'
        'console/charts/Histogram'
        'console/charts/Line'
        'console/charts/Ring'
        'console/charts/Scatter'
        'console/charts/Spoke'
], (ChartConfig, Chart, Canvas, ChartComponent, ChartConstraints, BackgroundXAxis, Bar, Disc, Graph, Grid, Histogram, Line, Ring, Scatter, Spoke) ->

  class Charts
    # General charts

    # Line chart
    @lineChart: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        graphPad: undefined
        xUnit: undefined
        xMax: 10
        xStep: calcTimeSteps(10)
        yUnit: undefined
        yMax: undefined
        yAxisFixed: false
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          xUnit: settings.xUnit
          xMax: settings.xMax
          xStep: settings.xStep
          yUnit: settings.yUnit
          yMax: settings.yMax
          graphPad: settings.graphPad || ChartConfig.padding.constraints
        }),
        new BackgroundXAxis(),
        new Grid({})
      )
      # Named components
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainBlue
        pushConstraints: !settings.yAxisFixed
      ), 'graph'
      # Bind mouse overs
      chart.bindMouseMove chart.components.graph,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # Bar chart
    @barChart: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        yUnit: String.fromCharCode(0xB5) + 's'
        xMax: 10
        xStep: calcTimeSteps(10)
        barCount: 10
        barWidthRatio: 0.85
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          yUnit: settings.yUnit
          xUnit: "min"
          xMax: settings.xMax
          xStep: settings.xStep
          graphPad: ChartConfig.padding.constraints
        }),
        new BackgroundXAxis(),
        new Grid()
      )
      # Named components
      chart.add new Bar(
        bgColor: ChartConfig.colors.graphFill
        color: ChartConfig.colors.mainBlue
        widthRatio: settings.barWidthRatio
        number: settings.barCount
      ), 'bars'
      # Bind mouse overs
      chart.bindMouseMove chart.components.bars,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # Scatter chart
    @scatterChart: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        yUnit: String.fromCharCode(0xB5) + 's'
        xMax: 10
        xStep: calcTimeSteps(10)
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints(
          xUnit: 'min'
          yUnit: settings.yUnit
          xMax: settings.xMax
          xStep: calcTimeSteps(10)
          graphPad: ChartConfig.padding.constraints
        ),
        new BackgroundXAxis(),
        new Grid()
      )
      # Named components
      chart.add new Scatter(
        dotColor: ChartConfig.colors.mainBlue
        font: ChartConfig.fonts.standard
        maxSampled: 1000
        smooth: 3
      ), 'scatter'
      # Bind mouse overs
      chart.bindMouseMove chart.components.scatter,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # Specific charts

    # Eye chart
    @eye: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        updateCallback: undefined
        size: 100
        updateOnResize: true
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.size
          height: settings.size
          animationDuration: ChartConfig.animation.duration
          updateOnResize: settings.updateOnResize
        ),
        new ChartConstraints(),
        # Background disc
        new Disc(
          radius: Math.floor(settings.size * 0.5)
          color: ChartConfig.colors.background
          shadow: null
        )
      )
      # Add named components
      chart.add new Ring(
        width: Math.floor(settings.size * 0.1)
        radius: Math.floor(settings.size * 0.5)
        color: ChartConfig.colors.line
        bgColor: ChartConfig.colors.grid
      ), 'outer'
      chart.add new Ring(
        width: Math.floor(settings.size * 0.1)
        radius: Math.floor(settings.size * 0.371)
        color: ChartConfig.colors.line
        bgColor: ChartConfig.colors.grid
      ), 'middle'
      chart.add new Ring(
        width: Math.floor(settings.size * 0.1)
        radius: Math.floor(settings.size * 0.24)
        color: ChartConfig.colors.line
        bgColor: ChartConfig.colors.grid
      ), 'inner'
      chart.add new Ring(
        animationDuration: 0
        width: Math.floor(settings.size * 0.05)
        radius: Math.floor(settings.size * 0.1)
        color: ChartConfig.colors.grid
        colorSwitches:
          error: ChartConfig.colors.error
          warning: ChartConfig.colors.warning
        bgColor: ChartConfig.colors.grid
      ), 'center'
      # Bind mouse overs
      for comp in ['outer', 'middle', 'inner', 'center']
        chart.bindMouseMove(
          chart.components[comp],
        (text, pos, comp) ->
          comp.setHighlighted true
          window.hoverPopup.text(text).position(pos.x, pos.y).show()
        , (comp) ->
          comp.setHighlighted false if comp
          window.hoverPopup.hide()
        )
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # System Throughput chart
    @systemThroughput: (settings = {}) ->
      settings = $.extend({}, {
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        xUnit: 'min'
        yUnit: 'msg/s'
        xMax: 10
        xStep: calcTimeSteps(10)
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          xUnit: settings.xUnit
          yUnit: settings.yUnit
          xMax: settings.xMax
          xStep: settings.xStep
          graphPad: ChartConfig.padding.constraints
        }),
        new BackgroundXAxis()
        new Grid({})
      )
      # Named components
      chart.add new Graph(
        fill: ChartConfig.colors.graphFill
        withHover: true
      ), 'graph'
      chart.add new Line(
        lineColor: ChartConfig.colors.error
      ), 'meanLine'
      # Bind mouse overs
      chart.bindMouseMove chart.components.graph,
        (text, pos, comp) ->
          window.hoverPopup.text(text).position(pos.x, pos.y).show()
        , (comp) ->
          window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # System remote throughput chart
    @remoteThroughput: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        yUnit: String.fromCharCode(0xB5) + 's'
        xMax: 10
        xStep: calcTimeSteps(10)
        barCount: 10
        barWidthRatio: 0.85
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          xUnit: 'min'
          yUnit: 'msg/s'
          xMax: settings.xMax
          xStep: settings.xStep
          graphPad: ChartConfig.padding.constraints
        }),
        new BackgroundXAxis(),
        new Grid(
          fill: '',
          yAxisNumberColor: ChartConfig.colors.gridText
        )
      )
      # Named components
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainGreyTransparent
      ), 'messageRate'
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainBlue
        shadowColor: null
      ), 'messageBytes'
      constraints = new ChartConstraints({
        yUnit: 'bytes/s'
        xMax: settings.xMax
        xStep: settings.xStep
        graphPad: ChartConfig.padding.constraints
      })
      chart.components.messageBytes.withConstraints constraints
      chart.add new Grid(
        drawX: false,
        drawGrid: false,
        yAxisRight: true,
        yAxisNumberColor: ChartConfig.colors.mainBlue
      ), 'grid'
      chart.components.grid.withConstraints constraints
      # Bind mouse overs
      chart.bindMouseMove chart.components.messageBytes,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # Mean latency
    @meanLatency: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        yUnit: String.fromCharCode(0xB5) + 's'
        xMax: 10
        xStep: calcTimeSteps(10)
        barCount: 10
        barWidthRatio: 0.85
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          yUnit: settings.yUnit
          xUnit: "min"
          xMax: settings.xMax
          xStep: settings.xStep
          graphPad: ChartConfig.padding.constraints
        }),
        new BackgroundXAxis(),
        new Grid()
      )
      # Named components - the order of bar charts is important here!
      chart.add new Bar(
        bgColor: ChartConfig.colors.graphFill
        color: ChartConfig.colors.mainRed
        widthRatio: settings.barWidthRatio
        number: settings.barCount
        pushConstraints: false
      ), 'barMin'
      chart.add new Bar(
        bgColor: ChartConfig.colors.graphFill
        color: ChartConfig.colors.mainBlue
        widthRatio: settings.barWidthRatio
        number: settings.barCount
      ), 'barMean'
      # Bind mouse overs
      chart.bindMouseMove chart.components.barMean,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # CPU combined
    @cpuCombined: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        xMax: 10
        xUnit: 'min'
        xStep: calcTimeSteps(10)
        yMax: 100
        yUnit: '%'
        yAxisFixed: false
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          xUnit: settings.xUnit
          yUnit: settings.yUnit
          xMax: settings.xMax
          yMax: settings.yMax
          xStep: settings.xStep
          graphPad: ChartConfig.padding.constraints
        }),
        new BackgroundXAxis(),
        new Grid({})
      )
      # Named components
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainYellow
        pushConstraints: !settings.yAxisFixed
      ), 'combined'
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainBlue
        pushConstraints: false
      ), 'system'
      # Bind mouse overs
      chart.bindMouseMove chart.components.combined,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # Latency histogram
    @latencyHistogram: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        xUnit: ''
        yUnit: '#'
        xMax: 10
        xStep: calcTimeSteps(10)
      }, settings)
      histogram = new Histogram()
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints(
          xUnit: settings.xUnit
          yUnit: settings.yUnit
          xMax: 10
          xStep: 10
          graphPad: ChartConfig.padding.constraints
        ),
        new BackgroundXAxis()
      )
      # Named components
      chart.add new Grid(
        histogram: histogram
      ), 'grid'
      chart.add histogram, 'histogram'
      # Bind mouse overs
      chart.bindMouseMove chart.components.histogram,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # Load Average
    @loadAverage: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        xUnit: 'min'
        yUnit: ''
        xMax: 10
        xStep: calcTimeSteps(10)
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          xUnit: settings.xUnit
          yUnit: settings.yUnit
          xMax: settings.xMax
          xStep: settings.xStep
          graphPad: ChartConfig.padding.constraints
        }),
        new BackgroundXAxis(),
        new Grid({})
      )
      # Named components
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainBlue
      ), 'avg1min'
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainYellow
        pushConstraints: false
      ), 'avg5min'
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainGrey
        pushConstraints: false
      ), 'avg15min'
      # Bind mouse overs
      chart.bindMouseMove chart.components.avg1min,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # Threads
    @threads: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        yUnit: ''
        xMax: 10
        xStep: calcTimeSteps(10)
        barCount: 10
        barWidthRatio: 0.85
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          yUnit: settings.yUnit
          xUnit: "min"
          xMax: settings.xMax
          xStep: settings.xStep
          graphPad: ChartConfig.padding.constraints
        }),
        new BackgroundXAxis(),
        new Grid()
      )
      # Named components
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainBlue
      ), 'threads'
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainGreen
        pushConstraints: false
      ), 'daemonThreads'
      # Bind mouse overs
      chart.bindMouseMove chart.components.threads,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart

    # Throughput
    @throughput: (settings = {}) ->
      settings = $.extend({
        container: undefined
        canvasId: undefined
        canvasClass: undefined
        width: undefined
        height: undefined
        yUnit: 'msg/s'
        xMax: 10
        xStep: calcTimeSteps(10)
      }, settings)
      chart = new Chart(
        new Canvas(
          id: settings.canvasId
          class: settings.canvasClass
          container: settings.container
          width: settings.width
          height: settings.height
          animationDuration: ChartConfig.animation.duration
          updateOnResize: true
        ),
        new ChartConstraints({
          yUnit: settings.yUnit
          xUnit: "min"
          xMax: settings.xMax
          xStep: settings.xStep
          graphPad: ChartConfig.padding.constraints
        }),
        new BackgroundXAxis(),
        new Grid({
          timestamp:false
        })
      )
      # Named components
      chart.add new Graph(
        lineColor: ChartConfig.colors.mainBlue
      ), 'graph'
      # Bind mouse overs
      chart.bindMouseMove chart.components.graph,
      (text, pos, comp) ->
        window.hoverPopup.text(text).position(pos.x, pos.y).show()
      , (comp) ->
        window.hoverPopup.hide()
      if settings.updateCallback then chart.bindUpdate settings.updateCallback
      chart
