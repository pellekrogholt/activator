define ['console/charts/Charts', 'console/charts/CommonCharts'], (Charts, CommonCharts) ->

  localChartSettings =
    height: 140
  
  availableCharts = {}

  # Import common charts
  for chart in ['askRate', 'bytesRead', 'bytesWritten', 'latency', 'latencyHistogram', 'latencyScatter', 'maxMailboxSize', 'meanMailboxSize', 'recieveRate', 'remoteRecieveRate', 'remoteSendRate', 'tellRate', 'timeInMailbox', 'totalMessageRate']
    availableCharts[chart] = CommonCharts[chart]

  availableCharts