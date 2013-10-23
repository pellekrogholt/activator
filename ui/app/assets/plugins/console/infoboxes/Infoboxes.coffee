define ['./Infobox', './timing', './Akkabox', './Sessionbox'], (Infobox, Timing, AkkaBox, SessionBox) ->

  class Infoboxes
    # Common infoboxes

    unitFormatter = (u, v) ->
      format.shorten(v) + (if u is '%' then '' else ' ') + u
    fixedVal = (u,v) ->
      ((v*1000).toFixed(0)/1000) + " " + u

    # Actor Counts
    @actorCounts:
      title: "Actor Counts"
      create: (settings = {}) ->
        settings = $.extend({
          class: "columnar fourColumns"
          fields:
            created:
              label: "Created"
            stopped:
              label: "Stopped"
            failures:
              label: "Failures"
            restarts:
              label: "Restarts"
          updateCallback: (data) ->
            mapped =
              created:
                value: data.actorStats.createdCount
              stopped:
                value: data.actorStats.stoppedCount
              failures:
                value: data.actorStats.failedCount
              restarts:
                value: data.actorStats.restartCount
            mapped
        }, settings)
        infobox = new Infobox settings

    # Deviations
    @deviations:
      title: "Deviations"
      create: (settings = {}) ->
        settings = $.extend({
          class: "compact"
          fields:
            errors:
              label: "Errors"
            warnings:
              label: "Warnings"
            unhandledMessages:
              label: "Unhandled Messages"
            deadLetters:
              label: "Deadletters"
            deadlocks:
              label: "Deadlocks"
              visible: false
            remote:
              label: "Remote Errors"
              visible: false
          updateCallback: (data) ->
            url = if data.console?.url? then (data.console.url + '/') else '#akka/'
            mapped =
              errors:
                value: data.deviations.errorCount
                url: url + "deviations"
              warnings:
                value: data.deviations.warningCount
                url: url + "deviations"
              unhandledMessages:
                value: data.deviations.unhandledMessageCount
                url: url + "deviations"
              deadLetters:
                value: data.deviations.deadLetterCount
                url: url + "deviations"
              deadlocks:
                visible: data.deviations.deadlockCount?
                value: data.deviations.deadlockCount
                url: url + "deviations"
              remote:
                visible: data.remoteStatus?
                value: if data.remoteStatus? then parseInt(data.remoteStatus.remoteServerError || 0, 10) + parseInt(data.remoteStatus.remoteClientError || 0, 10) + parseInt(data.remoteStatus.remoteServerWriteFailed || 0, 10) + parseInt(data.remoteStatus.remoteClientWriteFailed || 0, 10)
            mapped
        }, settings)
        infobox = new Infobox settings

    # Heap
    @heap:
      title: "Heap"
      create: (settings = {}) ->
        settings = $.extend({
          class: "ultraCompact"
          fields:
            used:
              label: "Used Heap"
            committed:
              label: "Committed Heap"
            max:
              label: "Max Heap"
            usedNon:
              label: "Used Non-Heap"
            maxNon:
              label: "Max Non-Heap"
            gcCount:
              label: "GC Count"
            gcActivity:
              label: "GC Activity"
          updateCallback: (data) ->
            mapped =
              used:
                value: format.units(data.systemmetrics.heapMemoryUnit, data.systemmetrics.usedHeap, unitFormatter)
              committed:
                value: format.units(data.systemmetrics.heapMemoryUnit , data.systemmetrics.committedHeap, unitFormatter)
              max:
                value: format.units(data.systemmetrics.heapMemoryUnit, data.systemmetrics.maxHeap, unitFormatter)
              usedNon:
                value: format.units(data.systemmetrics.heapMemoryUnit, data.systemmetrics.usedNonHeap, unitFormatter)
              maxNon:
                value: format.units(data.systemmetrics.heapMemoryUnit, data.systemmetrics.maxNonHeap, unitFormatter)
              gcCount:
                value: format.shorten(data.systemmetrics.gcCountPerMinute) + " / min"
              gcActivity:
                value: format.units("%", format.shorten(data.systemmetrics.gcTimePercent))
            mapped
        }, settings)
        infobox = new Infobox settings

    # Latency Percentiles - 1 hour
    @latencyPercentiles1hour:
      title: "Latency Percentiles - 1 hour"
      create: (settings = {}) ->
        settings = $.extend({
          class: "ultraCompact"
          fields:
            percentile1:
              label: "&hellip;"
            percentile2:
              label: "&hellip;"
            percentile3:
              label: "&hellip;"
            percentile4:
              label: "&hellip;"
            percentile5:
              label: "&hellip;"
            percentile6:
              label: "&hellip;"
            percentile7:
              label: "&hellip;"
            percentile8:
              label: "&hellip;"
          updateCallback: (data) ->
            mapped = {}
            if data.percentiles?.percentiles?
              position = 1
              unit = data.percentiles.percentiles.unit
              keys = Object.keys(data.percentiles.percentiles)
              # Use the first 8 elements in the object
              while position < 9
                key = keys[position - 1]
                mapped['percentile' + position] =
                  label: ""
                  value: ""
                if key != undefined and key != 'unit'
                  mapped['percentile' + position].label = key
                  mapped['percentile' + position].value = format.units(unit, data.percentiles.percentiles[key], unitFormatter)
                else
                  mapped['percentile' + position].value = ""
                position++
            mapped
        }, settings)
        infobox = new Infobox settings

    # Latency Summary
    @latencySummary:
      title: "Latency Summary"
      create: (settings = {}) ->
        settings = $.extend({
          class: "columnar"
          fields:
            min:
              label: "Min"
            mean:
              label: "Mean"
            max:
              label: "Max"
          updateCallback: (data) ->
            mapped =
              min:
                value: format.units(data.spanSummary.minDurationUnit, data.spanSummary.minDuration, unitFormatter)
              mean:
                value: format.units(data.spanSummary.meanDurationUnit, data.spanSummary.meanDuration, unitFormatter)
              max:
                value: format.units(data.spanSummary.maxDurationUnit, data.spanSummary.maxDuration, unitFormatter)
            mapped
        }, settings)
        infobox = new Infobox settings

    # Load
    @load:
      title: "Load"
      create: (settings = {}) ->
        settings = $.extend({
          class: "columnar eightColumns"
          fields:
            load1min:
              label: "Load Average 1 min"
            load5min:
              label: "Load Average 5 min"
            load15min:
              label: "Load Average 15 min"
            contextSwitches:
              label: "Context Switches"
            cpuCombined:
              label: "CPU Combined"
            cpuUser:
              label: "CPU User"
            cpuSystem:
              label: "CPU System"
            processors:
              label: "Processors"
          updateCallback: (data) ->
            mapped =
              load1min:
                value: if data.systemmetrics.loadAverage > 0 then format.shorten data.systemmetrics.loadAverage else "N/A"
              load5min:
                value: if data.systemmetrics.loadAverage5min > 0 then format.shorten data.systemmetrics.loadAverage5min else "N/A"
              load15min:
                value: if data.systemmetrics.loadAverage15min > 0 then format.shorten data.systemmetrics.loadAverage15min else "N/A"
              cpuCombined:
                value: format.units("%", format.shorten(data.systemmetrics.cpuCombined * 100))
              cpuUser:
                value: format.units("%", format.shorten(data.systemmetrics.cpuUser * 100))
              cpuSystem:
                value: format.units("%", format.shorten(data.systemmetrics.cpuSys * 100))
              contextSwitches:
                value: data.systemmetrics.contextSwitches
              processors:
                value: data.systemmetrics.availableProcessors
            mapped
        }, settings)
        infobox = new Infobox settings

    # Memory
    @memory:
      title: "Memory"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            usage:
              label: "Memory Usage"
            swapIn:
              label: "Swap Page In"
            swapOut:
              label: "Swap Page Out"
          updateCallback: (data) ->
            mapped =
              usage:
                value: format.units(data.systemmetrics.memUsageUnit, data.systemmetrics.memUsage, unitFormatter)
              swapIn:
                value: format.shorten data.systemmetrics.memSwapPageIn
              swapOut:
                value: format.shorten data.systemmetrics.memSwapPageOut
            mapped
        }, settings)
        infobox = new Infobox settings

    # Message Counts
    @messageCounts:
      title: "Message Counts"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            processed:
              label: "Processed"
            tell:
              label: "Tell"
            ask:
              label: "Ask"
            remoteWrite:
              label: "Remote Write"
            remoteRead:
              label: "Remote Read"
          updateCallback: (data) ->
            mapped =
              processed:
                value: Math.floor data.actorStats.processedMessagesCount
              tell:
                value: Math.floor data.actorStats.tellMessagesCount
              ask:
                value: Math.floor data.actorStats.askMessagesCount
              remoteWrite:
                value: format.units("bytes", data.actorStats.bytesRead, unitFormatter)
              remoteRead:
                value: format.units("bytes", data.actorStats.bytesWritten, unitFormatter)
            mapped
        }, settings)
        infobox = new Infobox settings

    # Message Rates
    @messageRates:
      title: "Message Rates"
      create: (settings = {}) ->
        settings = $.extend({
          class: "columnar eightColumns"
          fields:
            mean:
              label: "Mean"
            total:
              label: "Total"
            receive:
              label: "Receive"
            tell:
              label: "Tell"
            ask:
              label: "Ask"
            peakTotal:
              label: "Peak Total"
            peakReceive:
              label: "Peak Receive"
            peakTell:
              label: "Peak Tell"
          updateCallback: (data) ->
            rateUnit = data.actorStats.rateUnit
            mapped =
              mean:
                value: format.units(rateUnit, data.actorStats.meanProcessedMessageRate, unitFormatter).replace(" ", "<br>")
              total:
                value: format.units(rateUnit, data.actorStats.totalMessageRate, unitFormatter).replace(" ", "<br>")
              receive:
                value: format.units(rateUnit, data.actorStats.receiveRate, unitFormatter).replace(" ", "<br>")
              tell:
                value: format.units(rateUnit, data.actorStats.tellRate, unitFormatter).replace(" ", "<br>")
              ask:
                value: format.units(rateUnit, data.actorStats.askRate, unitFormatter).replace(" ", "<br>")
              peakTotal:
                value: format.units(rateUnit, data.actorStats.peakTotalMessageRate, unitFormatter).replace(" ", "<br>")
              peakReceive:
                value: format.units(rateUnit, data.actorStats.peakReceiveRate, unitFormatter).replace(" ", "<br>")
              peakTell:
                  value: format.units(rateUnit, data.actorStats.peakTellRate, unitFormatter).replace(" ", "<br>")
            mapped
        }, settings)
        infobox = new Infobox settings

    # Network
    @network:
      title: "Network"
      create: (settings = {}) ->
        settings = $.extend({
          class: "compact"
          fields:
            received:
              label: "Data Received"
            sent:
              label: "Data Sent"
            receiveErrors:
              label: "Receive Errors"
            sendErrors:
              label: "Send Errors"
            tcpEstablished:
              label: "TCP Restablished"
            tcpResets:
              label: "TCP Resets"
          updateCallback: (data) ->
            mapped =
              received:
                value: format.units(data.systemmetrics.netRxBytesRateUnit, data.systemmetrics.netRxBytesRate, unitFormatter)
              sent:
                value: format.units(data.systemmetrics.netTxBytesRateUnit, data.systemmetrics.netTxBytesRate, unitFormatter)
              receiveErrors:
                value: data.systemmetrics.netRxErrors
              sendErrors:
                value: data.systemmetrics.netTxErrors
              tcpEstablished:
                value: data.systemmetrics.tcpCurrEstab
              tcpResets:
                value: data.systemmetrics.tcpEstabResets
            mapped
        }, settings)
        infobox = new Infobox settings

    # Remote Message Rates
    @remoteMessageRates:
      title: "Remote Message Rates"
      create: (settings = {}) ->
        settings = $.extend({
          class: "compact"
          fields:
            sendMessages:
              label: "Send Messages"
            receiveMessages:
              label: "Receive Messages"
            receiveData:
              label: "Receive Data"
            sendData:
              label: "Send Data"
            meanReceiveData:
              label: "Mean Receive Data"
            meanSendData:
              label: "Mean Send Data"
          updateCallback: (data) ->
            rateUnit = data.actorStats.rateUnit
            mapped =
              sendMessages:
                value: format.units(rateUnit, data.actorStats.remoteReceiveRate, unitFormatter)
              receiveMessages:
                value: format.units(rateUnit, data.actorStats.remoteSendRate, unitFormatter)
              receiveData:
                value: format.units(data.actorStats.bytesReadRateUnit, data.actorStats.bytesReadRate, unitFormatter)
              sendData:
                value: format.units(data.actorStats.bytesWrittenRateUnit, data.actorStats.bytesWrittenRate, unitFormatter)
              meanReceiveData:
                value: format.units(data.actorStats.meanBytesReadRateUnit, data.actorStats.meanBytesReadRate, unitFormatter)
              meanSendData:
                value: format.units(data.actorStats.meanBytesWrittenRateUnit, data.actorStats.meanBytesWrittenRate, unitFormatter)
            mapped
        }, settings)
        infobox = new Infobox settings

    # Remote Status
    @remoteStatus:
      title: "Remote Status"
      create: (settings = {}) ->
        settings = $.extend({
          class: "ultraCompact"
          fields:
            serverStarted:
              label: "Server Started"
            clientStarted:
              label: "Client Started"
            serverShutdown:
              label: "Server Shutdown"
            clientShutdown:
              label: "Client Shutdown"
            serverConnected:
              label: "Server Connected"
            clientConnected:
              label: "Client Connected"
            serverDisconnected:
              label: "Server Disconnected"
            clientDisconnected:
              label: "Client Disconnected"
            serverClosed:
              label: "Server Closed"
          updateCallback: (data) ->
            mapped =
              serverStarted:
                value: data.remoteStatus.remoteServerStarted
              clientStarted:
                value: data.remoteStatus.remoteClientStarted
              serverShutdown:
                value: data.remoteStatus.remoteServerShutdown
              clientShutdown:
                value: data.remoteStatus.remoteClientShutdown
              serverConnected:
                value: data.remoteStatus.remoteServerClientConnected
              clientConnected:
                value: data.remoteStatus.remoteClientConnected
              serverDisconnected:
                value: data.remoteStatus.remoteServerClientDisconnected
              clientDisconnected:
                value: data.remoteStatus.remoteClientDisconnected
              serverClosed:
                value: data.remoteStatus.remoteServerClientClosed
            mapped
        }, settings)
        infobox = new Infobox settings

    # Threads
    @threads:
      title: "Threads"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            nonDaemonThreads:
              label: "Non-Daemon Threads"
            daemonThreads:
              label: "Daemon Threads"
            peakThreads:
              label: "Peak Threads"
          updateCallback: (data) ->
            mapped =
              nonDaemonThreads:
                value: data.systemmetrics.threadCount
              daemonThreads:
                value: data.systemmetrics.daemonThreadCount
              peakThreads:
                value: data.systemmetrics.peakThreadCount
            mapped
        }, settings)
        infobox = new Infobox settings

    # --------------------------------------------------------------
    # System infoboxes

    # System throughput
    @systemThroughput:
      title: "Throughput"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            total:
              label: "Total Message Rate"
            peak:
              label: "Peak Message Rate"
            mean:
              label: "Mean Message Rate"
            recieve:
              label: "Receive Rate"
            tell:
              label: "Tell Rate"
          updateCallback: (data) ->
            rateUnits = data.actorStats.rateUnit
            mapped =
              total:
                value: format.units(rateUnits, data.actorStats.totalMessageRate, unitFormatter)
              peak:
                value: format.units(rateUnits, data.actorStats.peakTotalMessageRate, unitFormatter)
                hoverText: 'At ' + format.formatTimestamp(data.actorStats.peakTotalMessageRateTimestamp)
              mean:
                value: format.units(data.actorStats.meanProcessedMessageRateUnit, data.actorStats.meanProcessedMessageRate, unitFormatter)
              recieve:
                value: format.units(rateUnits, data.actorStats.peakReceiveRate, unitFormatter)
                hoverText: "At: " + format.formatTimestamp(data.actorStats.peakReceiveRateTimestamp)
              tell:
                value: format.units(rateUnits, data.actorStats.peakTellRate, unitFormatter)
                hoverText: "At: " + format.formatTimestamp(data.actorStats.peakTellRateTimestamp)
            mapped
        }, settings)
        infobox = new Infobox settings

    # Scopes
    @scopes:
      title: "Scopes"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            nodes:
              label: "Nodes"
            actorSystems:
              label: "Actor Systems"
            dispatchers:
              label: "Dispatchers"
            actors:
              label: "Actors"
            tags:
              label: "Tags"
          updateCallback: (data) ->
            mapped =
              nodes:
                value: data.meta.nodeCount
              actorSystems:
                value: data.meta.actorSystemCount
              dispatchers:
                value: data.meta.dispatcherCount
              actors:
                value: data.meta.actorPathCount
              tags:
                value: data.meta.tagCount
            mapped
        }, settings)
        infobox = new Infobox settings

    # Mailbox
    @mailbox:
      title: "Mailbox"
      create: (settings = {}) ->
        settings = $.extend({
          class: "columnar"
          fields:
            maxSize:
              label: "Max Mailbox Size"
            maxTime:
              label: "Max Time in Mailbox"
            meanTime:
              label: "Mean Time in Mailbox"
          updateCallback: (data) ->
            mapped =
              maxSize:
                value: data.actorStats.maxMailboxSize
              maxTime:
                value: format.units(data.actorStats.maxTimeInMailboxUnit, data.actorStats.maxTimeInMailbox, unitFormatter)
              meanTime:
                value: format.units(data.actorStats.meanTimeInMailboxUnit, data.actorStats.meanTimeInMailbox, unitFormatter)
            mapped
        }, settings)
        infobox = new Infobox settings

    # Remote
    @remote:
      title: "Remote"
      create: (settings = {}) ->
        settings = $.extend({
          class: "columnar"
          fields:
            send:
              label: "Send Rate"
            recieve:
              label: "Recieve Rate"
            errors:
              label: "Remote Errors"
          updateCallback: (data) ->
            chk = (field) -> parseInt(data.remoteStatus[field] || 0, 10)
            mapped =
              send:
                value: format.units(data.actorStats.rateUnit, data.actorStats.remoteSendRate, unitFormatter).replace(' ', '<br>')
              recieve:
                value: format.units(data.actorStats.rateUnit, data.actorStats.remoteReceiveRate, unitFormatter).replace(' ', '<br>')
              errors:
                value: if data.remoteStatus? then chk("remoteServerError") + chk("remoteClientError") + chk("remoteServerWriteFailed") + chk("remoteClientWriteFailed")
            mapped
        }, settings)
        infobox = new Infobox settings

    # Node infoboxes

    # Node summary Infobox
    @nodeSummary:
      title: "Node Summary"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            uptime:
              label: "Uptime"
            maxQueue:
              label: "Max Queue"
            peakRates:
              label: "Peak Rates"
            errors:
              label: "Errors"
          updateCallback: (data) ->
            mapped =
              uptime:
                value: if data.systemmetrics.upTime? then format.humanReadableDuration(data.systemmetrics.upTime, data.systemmetrics.upTimeUnit)
              maxQueue:
                value: data.actorStats.maxMailboxSize
                url: if data.actorStats.maxMailboxSizeAddressPath.length > 0 then data.actorStats.maxMailboxSizeAddressPath else undefined
              peakRates:
                value: if data.actorStats.peakTellRate? then format.units(data.actorStats.rateUnit, data.actorStats.peakTellRate, unitFormatter)
              errors:
                value: parseInt(data.remoteStatus.remoteServerError || 0, 10) + parseInt(data.remoteStatus.remoteClientError || 0, 10) + parseInt(data.remoteStatus.remoteServerWriteFailed || 0, 10) + parseInt(data.remoteStatus.remoteClientWriteFailed || 0, 10)
            mapped
        }, settings)
        infobox = new Infobox settings


    # Dispatcher infoboxes

    # Executor
    @executor:
      title: "Executor"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            dispatcherType:
              label: "Dispatcher Type"
            corePoolSize:
              label: "Core Pool Size"
            largestPoolSize:
              label: "Largest Pool Size"
            poolSize:
              label: "Pool Size"
            queueSize:
              label: "Queue Size"
          updateCallback: (data) ->
            if data.dispatcherTimeSeries?.points?
              points = data.dispatcherTimeSeries.points
              points = points[points.length - 1]
            else
              points = []
            mapped =
              dispatcherType:
                value: if data.dispatcherTimeSeries?.dispatcherType then data.dispatcherTimeSeries.dispatcherType else "?"
              corePoolSize:
                value: if points then points.corePoolSize
              largestPoolSize:
                value: if points then points.largestPoolSize
              poolSize:
                value: if points then points.poolSize
              queueSize:
                value: if points then points.queueSize
            mapped
        }, settings)
        infobox = new Infobox settings

    # --------------------------------------------------------------
    # PLAY infoboxes

    # Play reqs
    @playRequests:
      title: "Requests"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            invocationCount:
              label: "Requests Count"
            totalInvocationRate:
              label: "Request Rate"
            meanInvocationRate:
              label: "Mean Message Rate"
            errorCount:
              label: "Errors"
          updateCallback: (data) ->
            invocationCount:
              value: data.invocationCount
              hoverText: 'At ' + format.formatTimestamp(data.latestInvocationTimestamp)
            totalInvocationRate:
              value: data.totalInvocationRate.toFixed(3) + " req/s"
            meanInvocationRate:
              value: data.meanInvocationRate.toFixed(3) + " req/s"
            errorCount:
              value: data.errorCount
              hoverText: "At: " + format.formatTimestamp(data.latestTraceEventTimestamp)
        }, settings)
        infobox = new Infobox settings

    # Play IO
    @playIO:
      title: "Up/Downloads"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            bytesWritten:
              label: "Bytes Written"
            meanBytesWrittenRate:
              label: "Mean Bytes Written"
            bytesRead:
              label: "Bytes Read"
            meanBytesReadRate:
              label: "Receive Rate"
          updateCallback: (data) ->
            bytesWritten:
              value: format.units("bytes", data.bytesWritten,fixedVal)
            meanBytesWrittenRate:
              value: format.units('bytes/second', data.meanBytesWrittenRate,fixedVal)
            bytesRead:
              value: format.units('bytes', data.bytesRead,fixedVal)
            meanBytesReadRate:
              value: format.units('bytes/second', data.meanBytesReadRate,fixedVal)
        }, settings)
        infobox = new Infobox settings

    # Play processing
    @playProcess:
      title: "Durations"
      create: (settings = {}) ->
        settings = $.extend({
          fields:
            meanDuration:
              label: "Mean"
            maxDuration:
              label: "Max"
            meanInputProcessingDuration:
              label: "Mean Input Processing"
            meanActionExecutionDuration:
              label: "Mean Action Execution"
            meanOutputProcessingDuration:
              label: "Mean Output Processing"
          updateCallback: (data) ->
            meanDuration:
              value: format.units("milliseconds", data.meanDuration,fixedVal)
            maxDuration:
              value: format.units("milliseconds", (data.maxDuration/1000000),fixedVal)
            meanInputProcessingDuration:
              value: format.units("milliseconds", data.meanInputProcessingDuration,fixedVal)
            meanActionExecutionDuration:
              value: format.units("milliseconds", data.meanActionExecutionDuration,fixedVal)
            meanOutputProcessingDuration:
              value: format.units("milliseconds", data.meanOutputProcessingDuration,fixedVal)
        }, settings)
        infobox = new Infobox settings


    # Play request details
    @playRequestTiming:
      title: "Timing"
      class: "smallHeight"
      create: (settings = {})->
        infobox = new Timing settings

    @playRequestNetwork:
      title: "Network"
      create: (settings = {})->
        settings = $.extend
          fields:
            bytesIn:
              label: "Bytes In"
            bytesOut:
              label: "Bytes Out"
            host:
              label: "Host"
            node:
              label: "Node"
            domain:
              label: "Domain"
          updateCallback: (data) ->
            bytesIn:
              value: data.bytesIn
            bytesOut:
              value: data.bytesOut
            host:
              value: data.host
            node:
              value: data.node
            domain:
              value: data.invocationInfo?.domain
        , settings
        infobox = new Infobox settings

    @playRequestResponse:
      title: "Response"
      create: (settings = {})->
        settings = $.extend
          fields:
            summaryType:
              label: "Result"
            httpResponseCode:
              label: "Code"
            type:
              label: "Type"
            controller:
              label: "Controller"
            method:
              label: "Method"
          updateCallback: (data) ->
            summaryType:
              value: data.summaryType
            httpResponseCode:
              value: data.response.httpResponseCode
            type:
              value: data.response.type
            controller:
              value: data.invocationInfo.controller
            method:
              value: data.invocationInfo.method
        , settings
        infobox = new Infobox settings

    @playRequestRequest:
      title: "Request"
      class: "autoHeight"
      create: (settings = {})->
        settings = $.extend
          fields:
            httpMethod:
              label: "Http Method"
            path:
              label: "Path"
            host:
              label: "Host"
            remoteAddress:
              label: "Remote Address"
            version:
              label: "Version"
            id:
              label: "Id"
            method:
              label: "Method"
            uri:
              label: "Uri"

          updateCallback: (data) ->
            httpMethod:
              value: data.invocationInfo.httpMethod
            path:
              value: data.invocationInfo.path
            host:
              value: data.invocationInfo.host
            remoteAddress:
              value: data.invocationInfo.remoteAddress
            version:
              value: data.invocationInfo.version
            id:
              value: data.requestInfo.id
            method:
              value: data.requestInfo.method
            uri:
              value: data.requestInfo.uri
        , settings
        infobox = new Infobox settings

    @playSession:
      title: "Session"
      create: (settings = {})->
        settings = $.extend
          class: "session"
        , settings
        infobox = new SessionBox settings

    @playRequestHeaders:
      title: "Headers"
      class: "autoHeight"
      create: (settings = {})->
        settings = $.extend
          fields:
            'Accept':
              label:"Header Accept"
            'Accept-Encoding':
              label:"Header Accept-Encoding"
            'Accept-Language':
              label:"Header Accept-Language"
            'Connection':
              label:"Header Connection"
            'Cookie':
              label:"Header Cookie"
            'Host':
              label:"Header Host"
            'Referer':
              label:"Header Referer"
            'User-Agent':
              label:"Header User-Agent"
            'X-Requested-With':
              label:"Header X-Requested-With"
          updateCallback: (data) ->
            'Accept':
              value: data.requestInfo.headers['Accept']
            'Accept-Encoding':
              value: data.requestInfo.headers['Accept-Encoding']
            'Accept-Language':
              value: data.requestInfo.headers['Accept-Language']
            'Connection':
              value: data.requestInfo.headers['Connection']
            'Cookie':
              value: data.requestInfo.headers['Cookie']
            'Host':
              value: data.requestInfo.headers['Host']
            'Referer':
              value: data.requestInfo.headers['Referer']
            'User-Agent':
              value: data.requestInfo.headers['User-Agent']
            'X-Requested-With':
              value: data.requestInfo.headers['X-Requested-With']
        , settings
        infobox = new Infobox settings


    @playRequestAkka:
      title: "Akka"
      class: "autoHeight"
      create: (settings = {})->
        infobox = new AkkaBox settings

  Infoboxes
