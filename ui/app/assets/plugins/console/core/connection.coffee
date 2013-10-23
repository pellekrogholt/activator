define ->
  class Connection
    websocket: undefined
    connected: false
    sendQueue: []
    modules: []
    request: {}
    recieveCallbacks: []

    constructor: ->

    init: (initialtime) ->
      @request.time = initialtime
      @

    registerRecieveCallback: (callback) ->
      @recieveCallbacks.push callback
      @

    open: (url, onOpenCallback) ->
      @close()
      @websocket = new WebSocket(url)
      @websocket.onerror = (event) ->
        $(window).trigger("console-alert", {message: "Connection error", level: "error"})
        debug && console.log "Websocket error : ", event
      @websocket.onopen = (event) =>
        @connected = true
        debug && console.log "Websocket opened : ", event
        # Send queued messages
        messages = @sendQueue
        @sendQueue = []
        @send message for message in messages
        # Run callback
        onOpenCallback event if onOpenCallback?
      @websocket.onmessage = (event) =>
        @receive event.data
      @websocket.onclose = (event) =>
        $(window).trigger("console-alert", {message: "Connection closed", level: "warning"})
        debug && console.log "Websocket closing : ", event

    close: ->
      if @websocket
        @connected = false
        @websocket.close()
        @sendQueue = []
      @

    send: (message) ->
      message = JSON.stringify message
      if @connected
        debug && console.log "connection send : ", message
        @websocket.send message
      else
        @sendQueue.push message
        debug && console.log "connection queued message : ", message
      @

    receive: (message) ->
      try
        message = JSON.parse(message)
        $(window).trigger("network-data")
      catch e
        debug && console.log "connection couldn't parse recieved JSON message : ", message
        $(window).trigger("network-error")
        return false
      debug && console.log "connection recieve : ", message
      # Catch errors

      # Update module with data
      for module in @modules
        # Match modules with loaded module object's data types
        if module.module?.dataTypes? and message.type in module.module.dataTypes
          #console.log "connection update :", message.type, " | ", module.module.dataTypes.join(", ")
          # If module has id, match id with data
          if !module.module.id? or !message.name? or (module.module.id? and message.name? and message.name is module.module.id)
            # console.log "connection update module : ", message.type, if module.module.id? then module.module.id else "-"
            module.module.onData message.data

      # Run recieve callbacks
      callback(message) for callback in @recieveCallbacks

      @

    # updateModules: (modules) ->
    #   console.log "connection modules updated : ", modules
    #   @modules.latest = @modules.current.map (module) -> module.id
    #   @modules.current = modules
    #   @update()
    #   @

    # Update all modules
    updateModules: (modules)=>
      @modules = modules if modules?
      @request.modules = []

      # THIS REPEAT SCOPE FOR BACKEND
      # for each modules passed
      for index, m of @modules
        # Get connection parameters
        if m.module.getConnectionParameters
          current = m.module.getConnectionParameters()
          # We copy the previous object's scope
          if @request.modules.length > 0
            previousScope = @request.modules[ @request.modules.length - 1 ].scope
            current.scope = $.extend({}, previousScope, current.scope)
          @request.modules.push(current)
        # Register connection update callback on modules
        if not m.module.updateConnection?
          m.module.updateConnection = () =>
            @updateModules()

      @update() # Or @send()
      @

    updateTime: (time, minutes) ->
      debug && console.log "connection updateTime : ", time, minutes
      @request.time = time
      @update() # Or @send()
      for m in @modules
        m.module.onTimeUpdateMinutes minutes if m.module.onTimeUpdateMinutes
      @

    getTimeInMinutes: (startTime, endTime) ->
      Math.ceil(new Date(endTime).getTime() - new Date(startTime).getTime()) / 60000

    update: ->
      # Futur:
      # @send @request
      debug && console.log "connection request : ", @request

      ###
      sendData = {
        modules: [
          {
            "name" : "system",
            "scope" : {}
          }
        ],
        time: { startTime: "", endTime: "", rolling: "10minutes"}
      }
      ###

      # Build request object
      sendData = @request.modules
      sendData =
        modules: []
      sentModules = []
      # Only request each specific module once
      # TODO: Better handling of duplicate modules in request?
      for module in @request.modules
        if module.name not in sentModules
          sentModules.push module.name
          sendData.modules.push module
      # Todo: Add time from time machine object
      sendData.time = @request.time
      @send sendData
      @

  new Connection()
