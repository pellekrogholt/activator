define ['console/charts/Charts', 'console/core/timemachine'], (Charts, Timemachine) ->

  localChartSettings =
    height: 130

  availableCharts =
    throughput:
      title: "Throughput"
      create: (container) ->
        Charts.systemThroughput
          container: container
          height: localChartSettings.height
          xMax: Timemachine.getMinutes()
          xStep: calcTimeSteps Timemachine.getMinutes()
          updateCallback: (data) ->
            mapped =
              graph:
                data: if data.messageRate? then zip(data.messageRate.data.timestamp, data.messageRate.data.receiveRate) else []
              meanLine:
                y: if data.actorStats.meanProcessedMessageRate? then data.actorStats.meanProcessedMessageRate else null
            mapped
    timeInMailBox:
      title: "Time in Mailbox"
      create: (container) ->
        Charts.barChart
          container: container
          height: localChartSettings.height
          xMax: Timemachine.getMinutes()
          xStep: calcTimeSteps Timemachine.getMinutes()
          barCount: Timemachine.getMinutes()
          yUnit: String.fromCharCode(0xB5) + 's'
          updateCallback: (data) ->
            timeInMailboxData = []
            if data.actorStatsBars?.bars?
              timeInMailboxData = data.actorStatsBars.bars.reduce ((ac, el) ->
                ac.push el.meanTimeInMailbox / 1000 # FIXME: would love to have a number formatter instead of this hard coded division
                ac
              ), []
            mapped =
              bars:
                data:
                  values: timeInMailboxData
                  shift: Timemachine.getMinuteRatio()
            mapped
    remoteThroughput:
      title: "Remote Throughput"
      create: (container) ->
        Charts.remoteThroughput
          container: container
          height: localChartSettings.height
          xMax: Timemachine.getMinutes()
          xStep: calcTimeSteps Timemachine.getMinutes()
          updateCallback: (data) ->
            mapped =
              messageRate:
                data: if data.messageRate then zip data.messageRate.data.timestamp, data.messageRate.data.remoteSendRate else []
              messageBytes:
                data: if data.messageRate then zip data.messageRate.data.timestamp, data.messageRate.data.bytesWrittenRate else []
            mapped
    meanLatency:
      title: "Mean Latency"
      create: (container) ->
        Charts.meanLatency
          container: container
          height: localChartSettings.height
          xMax: Timemachine.getMinutes()
          xStep: calcTimeSteps Timemachine.getMinutes()
          updateCallback: (data) ->
            if data.spanSummaryBars?.bars?
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
                  values: latencyMeanDuration || []
                  shift: Timemachine.getMinuteRatio()
              barMin:
                data:
                  values: latencyMinDuration || []
                  shift: Timemachine.getMinuteRatio()
            mapped

  availableCharts
