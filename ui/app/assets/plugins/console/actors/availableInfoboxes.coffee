define ['console/infoboxes/Infoboxes'], (Infoboxes) ->

  availableInfoboxes = {}

  for infobox in ['actorCounts', 'deviations', 'latencyPercentiles1hour', 'latencySummary', 'messageCounts', 'messageRates', 'remoteMessageRates']
    availableInfoboxes[infobox] = Infoboxes[infobox]

  availableInfoboxes