define ['console/core/connection', 'console/utils/Settings'], (Connection, Settings) ->
  class Timemachine
    dom: undefined
    time: {}
    timeDefault:
      startTime: ""
      endTime: ""
      rolling: "10minutes"
    minutes: 10
    blinking: false

    constructor: () ->
      # Get saved or default time
      @time = Settings.get "console." + serverAppVersion + ".time", @timeDefault
      @minutes = if @time.rolling then parseInt @time.rolling else undefined
      # Set up UI
      @dom = $('#timemachine')
      @dom.find('#timelapse select').val @time.rolling if @time.rolling
      # Bind UI events
      @dom.on('change', '#timepref input[name=timepref]', (e) =>
        debug && console.log "timemachine timepref change : ", e
        if $(e.target).val() is 'live'
          $('#timelapse', @dom).show()
          $('#timerange', @dom).hide()
          @setLive $('#timelapse select', @dom).val()
        else
          $('#timelapse', @dom).hide()
          $('#timerange', @dom).show()
          @setSpan $('#timerange [name=start]', @dom).val(), $('#timerange [name=end]', @dom).val()
      )
      .on('change', '#timelapse select', (e) =>
          @minutes = parseInt $(e.target).val()
          @setLive $(e.target).val()
      )
      .on('submit', '#timerange', (e) =>
          e.preventDefault()
          @setSpan $('#timerange [name=start]', @dom).val(), $('#timerange [name=end]', @dom).val()
      )

    getTime: ->
      @time

    # Return number of minutes in current rolling range or time range
    getMinutes: ->
      # Calculate minutes if not set
      if not @minutes
        if @time.rolling
          @minutes = parseInt @time.rolling
        else
          @minutes = Math.ceil (new Date(@time.endTime).getTime() - new Date(@time.startTime).getTime()) / 60000
      @minutes

    # How far into the minute we currently are for rolling range
    # Return unit ratio, and 1.0 for set time ranges
    getMinuteRatio: ->
      if @time.rolling then (Date.now() % 60000) / 60000 else 1.0

    setLive: (range) ->
      debug && console.log "timemachine live : ", range
      @time =
        rolling: range
      Connection.updateTime @time, parseInt range
      @saveTime @time
      @

    setSpan: (start, end) ->
      debug && console.log "timemachine span : ", start, end
      @time =
        start: @localTimeToUTC(start)
        end: @localTimeToUTC(end)
      Connection.updateTime @time, @getTimeInMinutes start, end
      @saveTime @time
      @

    localTime: (str) ->
      if str.indexOf(" ") < 0
        # assume it's just time without a date
        today = format.formatDate(new Date(), UTC = false)
        new Date(today + " " + str)
      else
        new Date(str)

    localTimeToUTC: (str) ->
      local = @localTime(str)
      if isNaN(local.getTime())
        undefined
      else
        format.formatDate(local) + "_" + format.formatTime(local, seconds = false)

    getTimeInMinutes: (startTime, endTime) ->
      Math.ceil(@localTime(endTime).getTime() - @localTime(startTime).getTime()) / 60000

    saveTime: (time) ->
      Settings.set "console." + globals.version.toString() + ".time", time
      @

    onData: ->
      #$('.blinker', @dom).fadeOut('fast').fadeIn('fast')
      @

    # Check if datetime string is valid
    checkDatetime: (datetime) ->
      if Object.prototype.toString.call(d) == "[object Date]"
        if isNaN d.getTime()
          return false
        else
          return true
      else
        return false

  new Timemachine()