define ['console/infoboxes/Infoboxes'], (Infoboxes) ->

  availableInfoboxes = {}

  for infobox in ['systemThroughput', 'scopes', 'deviations', 'mailbox', 'remote']
    availableInfoboxes[infobox] = Infoboxes[infobox]

  availableInfoboxes