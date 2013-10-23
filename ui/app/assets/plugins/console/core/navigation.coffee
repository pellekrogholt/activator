define ["console/utils/Settings"], (Settings) ->

  init: ->
    # NAVIGATION PANNEL
    # Add effects on mouseover to toggle the pan
    # $("body > nav").click((e) ->
    #   if e.target is e.currentTarget
    #     $("body").toggleClass("left-open")
    #     setTimeout(->
    #       $(window).trigger "resize"
    #     ,500)
    # )

    # $("body").addClass("left-open") if Settings.get("console.navigation.open","close") == "open"

    $("#switch").click (e) ->
      e.preventDefault()
      $("#navigation").show()

    $("#navigation").click (e) ->
      $("#navigation").hide()

      # $("body").toggleClass("left-open")
      # setTimeout(->
      #   $(window).trigger "resize"
      # ,500)
      # Settings.set "console.navigation.open", if $("body").is(".left-open") then "open" else "closed"
