define [], () ->

  window.localStorage.settings ?= "{}"
  json = JSON.parse window.localStorage.settings

  settings = (label, value)->
    if value?
      json[label] = value
      window.localStorage.settings = JSON.stringify json
      json
    else if label?
      json[label]
    else
      window.localStorage.settings = JSON.stringify json
      json

  set: (label, value)->
    settings(label, value)

  get: (label, def)->
    return settings(label) || def

  reset: (label)->
    json.removeItem('label')
    settings()

  resetAll: ()->
    window.localStorage.settings = "{}"
    json = {}

