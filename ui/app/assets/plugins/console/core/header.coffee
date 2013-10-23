define ['console/core/alerts'], (alerts) ->
  init: ->
    #@el = $("body > header")
    @settings = $("#settings").on "click", "dt", (e)=>
      e.preventDefault()
      @settings.toggleClass("open")
      false
    @breadcrumb = $("#breadcrumb")

    @activity = $("#network .activity")
    @activity.on "webkitAnimationEnd mozAnimationEnd animationEnd", ()=>
      @activity.css
        webkitAnimation: ''
        mozAnimation: ''
        animation: ''

    $(window).on "network-data", (e)=>
      @activity.css
        'webkitAnimation': "blinkborder 1s 1 linear"
        'mozAnimation': "blinkborder 1s 1 linear"
        'animation': "blinkborder 1s 1 linear"
    $(window).on "network-error", (e)=>
      @activity.css
        'webkitAnimation': "blinkerror 200ms 5 linear"
        'mozAnimation': "blinkerror 200ms 5 linear"
        'animation': "blinkerror 200ms 5 linear"

    $(window).on "console-alert", (e, alertData) =>
      alerts.show(alertData.message, alertData.level || "alert", alertData.timeout || 0) if alertData.message

  update: (modules) ->
    @breadcrumb = $("#breadcrumb") if @breadcrumb is undefined
    @breadcrumb.html(
      modules.map((i)->
        if (i)
          title = i.module.breadcrumb || i.url
          "<a href=\"#"+i.args.pathEncoded+"\">"+title+"</a>"
        else
          ""
      ).join("")
    )
    modules
