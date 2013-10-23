define ->
  class Alerts
    dom: undefined
    timeout: undefined

    constructor: () ->
      @dom = $('#alerts')
      .on('click', '.close', (e) =>
        @hide()
      )
      @

    show: (message, level = "message", hideTimeout = 0) ->
      @dom.removeClass('error warning alert').addClass(level)
      .find('.message').html(message).end()
      .slideDown(200)
      clearTimeout @timeout if @timeout
      if hideTimeout
        @timeout = setTimeout(() =>
          @hide()
        , hideTimeout * 1000)
      @

    hide: ->
      @dom.slideUp(200, ->
        $(@).find('.message').html("")
      )
      @

  new Alerts()