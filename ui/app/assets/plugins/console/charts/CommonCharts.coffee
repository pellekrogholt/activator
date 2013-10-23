define ['console/charts/Charts', 'console/charts/ChartConfig', 'console/core/timemachine'], (Charts, ChartConfig, Timemachine) ->

  localChartSettings =
    height: 140

  CommonCharts =
    # Ask rate
    askRate:
      title: "Ask Rate"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'msg/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.askRate) else []
            mapped

    # Bytes read
    bytesRead:
      title: "Bytes Read"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'b/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.bytesReadRate) else []
            mapped

    # Bytes written
    bytesWritten:
      title: "Bytes Written"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'b/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.bytesWrittenRate) else []
            mapped

    # Context switches
    contextSwitches:
      title: "Context switches"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'ctx/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.systemmetricsTimeSeries.contextSwitches? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.contextSwitches) else []
            mapped

    # CPU combined
    cpuCombined:
      title: "CPU"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.cpuCombined
          container: container
          height: localChartSettings.height
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              combined:
                data: if data.systemmetricsTimeSeries.cpuCombined? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.cpuCombined.map (v) -> v*100) else []
              system:
                data: if data.systemmetricsTimeSeries.cpuSys? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.cpuSys.map (v) -> v*100) else []
            mapped

    # CPU combined (fixed Y-axis)
    cpuCombinedFixed:
      title: "CPU (fixed)"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.cpuCombined
          container: container
          height: localChartSettings.height
          xMax: minutes
          xStep: steps
          yAxisFixed: true
          updateCallback: (data) ->
            mapped =
              combined:
                data: if data.systemmetricsTimeSeries.cpuCombined? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.cpuCombined.map (v) -> v*100) else []
              system:
                data: if data.systemmetricsTimeSeries.cpuSys? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.cpuSys.map (v) -> v*100) else []
            mapped

    # CPU System
    cpuSystem:
      title: "CPU System"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: '%'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.systemmetricsTimeSeries.cpuSys? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.cpuSys.map (v) -> v*100) else []
            mapped

    # CPU System (fixed Y-axis)
    cpuSystemFixed:
      title: "CPU System (fixed)"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: '%'
          xMax: minutes
          xStep: steps
          yMax: 100
          yAxisFixed: true
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.systemmetricsTimeSeries.cpuSys? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.cpuSys.map (v) -> v*100) else []
            mapped

    # CPU User
    cpuUser:
      title: "CPU User"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: '%'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.systemmetricsTimeSeries.cpuUser? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.cpuUser.map (v) -> v*100) else []
            mapped

    # CPU User (fixed Y-axis)
    cpuUserFixed:
      title: "CPU User (fixed)"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: '%'
          xMax: minutes
          xStep: steps
          yMax: 100
          yAxisFixed: true
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.systemmetricsTimeSeries.cpuUser? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.cpuUser.map (v) -> v*100) else []
            mapped

    # Dispatcher threads
    dispatcherThreads:
      title: "Dispatcher threads"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: ''
          xUnit: 'min'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.dispatcherTimeSeries? then data.dispatcherTimeSeries.points.map( (o) -> [o.timestamp, o.activeThreadCount] )
            mapped

    # GC Actvity
    gcActivity:
      title: "GC Activity"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          graphPad: ChartConfig.padding.extraY
          xMax: minutes
          xStep: steps
          xUnit: 'min'
          yUnit: '%'
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.systemmetricsTimeSeries.gcTimePercent? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.gcTimePercent) else []
            mapped

    # GC Count
    gcCount:
      title: "GC Count"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: '#/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.systemmetricsTimeSeries.gcCountPerMinute? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.gcCountPerMinute) else []
            mapped

    # Heap
    heap:
      title: "Heap"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          xUnit: 'min'
          yUnit: '%'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            heap = []
            for i, usedHeap of data.systemmetricsTimeSeries.usedHeap
              heap.push (usedHeap / data.systemmetricsTimeSeries.maxHeap[i]) * 100
            mapped =
              graph:
                data: zip data.systemmetricsTimeSeries.timestamp, heap
            mapped

    # Latency
    latency:
      title: "Latency"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.meanLatency
          container: container
          height: localChartSettings.height
          xMax: minutes
          xStep: steps
          barCount: minutes
          updateCallback: (data) ->
            if data.spanSummaryBars
              latencyMeanDuration = data.spanSummaryBars.bars.reduce ((ac, el) ->
                ac.push el.meanDuration
                ac
              ), []
              latencyMinDuration = data.spanSummaryBars.bars.reduce ((ac, el) ->
                ac.push el.minDuration
                ac
              ), []
              mapped =
                barMean:
                  data:
                    values: latencyMeanDuration
                    shift: Timemachine.getMinuteRatio()
                barMin:
                  data:
                    values: latencyMinDuration
                    shift: Timemachine.getMinuteRatio()
              mapped

    # Latency histogram
    latencyHistogram:
      title: "Latency Histogram"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.latencyHistogram
          container: container
          height: localChartSettings.height
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped = {}
            if data.spanHistogram?
              mapped =
                histogram:
                  data: data.spanHistogram.buckets or []
                  boundaries: data.spanHistogram.bucketBoundaries or []
                grid:
                  xUnit: if data.spanHistogram.bucketBoundariesUnit then format.units(data.spanHistogram.bucketBoundariesUnit, 0, (u) -> u) else ''
            mapped

    # Latency Scatter
    latencyScatter:
      title: "Latency Scatter"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.scatterChart
          container: container
          height: localChartSettings.height
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              scatter:
                data: if data.spanTimeSeries? then data.spanTimeSeries.points else []
            mapped

    # Load Average
    loadAverage:
      title: "Load Average"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.loadAverage
          container: container
          height: localChartSettings.height
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              avg1min:
                data: if data.systemmetricsTimeSeries? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.loadAverage1min) else []
              avg5min:
                data: if data.systemmetricsTimeSeries? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.loadAverage5min) else []
              avg15min:
                data: if data.systemmetricsTimeSeries? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.loadAverage15min) else []
            mapped

    # Mailbox Size
    mailboxSize:
      title: "Mailbox Size"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: ''
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.mailboxTimeSeries? then data.mailboxTimeSeries.points.map( (o) -> [o.timestamp, o.size]) else []
            mapped

    # Mailbox Wait Time
    mailboxWaitTime:
      title: "Mailbox Wait Time"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: ''
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.mailboxTimeSeries? then data.mailboxTimeSeries.points.map( (o) -> [o.timestamp, o.waitTime]) else []
            mapped

    # Max Mailbox Size
    maxMailboxSize:
      title: "Max Mailbox Size"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.barChart
          container: container
          height: localChartSettings.height
          yUnit: ''
          xMax: minutes
          xStep: steps
          barCount: minutes
          updateCallback: (data) ->
            maxMailboxSizeData = []
            if data.actorStatsBars
              maxMailboxSizeData = data.actorStatsBars.bars.reduce ((ac, el) ->
                ac.push el.maxMailboxSize
                ac
              ), []
            mapped =
              bars:
                data:
                  values: maxMailboxSizeData
                  shift: Timemachine.getMinuteRatio()
            mapped

    # Mean Mailbox Size
    meanMailboxSize:
      title: "Mean Mailbox Size"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.barChart
          container: container
          height: localChartSettings.height
          yUnit: ''
          xMax: minutes
          xStep: steps
          barCount: minutes
          updateCallback: (data) ->
            meanMailboxSizeData = []
            if data.actorStatsBars
              actorStatsBarsData = if data.actorStatsBars.bars?.actors? then data.actorStatsBars.bars.actors else data.actorStatsBars.bars
              meanMailboxSizeData = actorStatsBarsData.reduce ((ac, el) ->
                ac.push el.meanMailboxSize
                ac
              ), []
            mapped =
              bars:
                data:
                  values: meanMailboxSizeData
                  shift: Timemachine.getMinuteRatio()
            mapped

    # Queue Size
    queueSize:
      title: "Queue Size"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: ''
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.dispatcherTimeSeries? then data.dispatcherTimeSeries.points.map( (o) -> [o.timestamp, o.queueSize] )
            mapped

    # Receive Rate
    recieveRate:
      title: "Receive Rate"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'msg/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.receiveRate) else []
            mapped

    # Remote Receive Rate
    remoteRecieveRate:
      title: "Remote Receive Rate"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'msg/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.remoteReceiveRate) else []
            mapped

    # Remote Send Rate
    remoteSendRate:
      title: "Remote Send Rate"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'msg/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.remoteSendRate) else []
            mapped

    # Tell Rate
    tellRate:
      title: "Tell Rate"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'msg/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.tellRate) else []
            mapped

    # Threads
    threads:
      title: "Threads"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.threads
          container: container
          height: localChartSettings.height
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              threads:
                data: if data.systemmetricsTimeSeries? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.threadCount) else []
              daemonThreads:
                data: if data.systemmetricsTimeSeries? then zip(data.systemmetricsTimeSeries.timestamp, data.systemmetricsTimeSeries.daemonThreadCount) else []
            mapped

    # Time In Mailbox
    timeInMailbox:
      title: "Time In Mailbox"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.barChart
          container: container
          height: localChartSettings.height
          yUnit: String.fromCharCode(0xB5) + 's'
          xMax: minutes
          xStep: steps
          barCount: minutes
          updateCallback: (data) ->
            timeInMailboxData = []
            if data.actorStatsBars
              actorBarData = if data.actorStatsBars.bars?.actors? then data.actorStatsBars.bars.actors else data.actorStatsBars.bars
              timeInMailboxData = actorBarData.reduce ((ac, el) ->
                ac.push el.meanTimeInMailbox / 1000
                # FIXME: would love to have a number formatter instead of this hard coded division
                ac
              ), []
            mapped =
              bars:
                data:
                  values: timeInMailboxData
                  shift: Timemachine.getMinuteRatio()
            mapped

    # Total Message Rate
    totalMessageRate:
      title: "Total Message Rate"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.lineChart
          container: container
          height: localChartSettings.height
          yUnit: 'msg/s'
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.totalMessageRate) else []
            mapped

    # Throughput
    throughput:
      title: "Throughput"
      create: (container) ->
        minutes = Timemachine.getMinutes()
        steps = calcTimeSteps Timemachine.getMinutes()
        Charts.throughput
          container: container
          xMax: minutes
          xStep: steps
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.throughput? then zip(data.throughput.timestamp, data.throughput.totalMessageRate) else []
            mapped

  CommonCharts
