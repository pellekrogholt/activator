define ['console/helpers/list'], (listHelper) ->


  # KEYBOARD NAVIGATION
  leftkey = (current) ->
    # Looks like it's the first module
    if !current.prev().length
      $("#navigation").show().addClass("focus")
      listHelper.activate($("#navigation .rockets a"))
      $("#consoleWrapper > *").removeClass("focus")
    else
      target = current.removeClass("focus").prev().addClass("focus")
      listHelper.adjustScroll(target)

  rightkey = (current) ->
    # What is it?
    #-> LIST
    if current.is("#navigation")
      $("#navigation").hide().removeClass("focus")
      $("#consoleWrapper > *").first().addClass("focus")
      link = current.find(".focus").attr("href")
      if link?
        window.location.hash = link

    else
      changed = listHelper.gotoRight(current) if current.hasClass("list")
      if !changed
        target = current.removeClass("focus").next().getOrElse("#consoleWrapper > *:last-child").addClass("focus")
        listHelper.activateList(target) if target.hasClass("list")
        listHelper.adjustScroll(target)

  upkey = (current) ->
    # What is it?
    #-> LIST
    if current.hasClass("list")
      listHelper.gotoUp(current)
    else if current.is("#navigation")
      list = current.find(".rockets a")
      target = list
        .filter(".focus").removeClass("focus")
        .prev().getOrElse(list.first())
        .addClass("focus")

    return false

  downkey = (current) ->
    # What is it?
    #-> LIST
    if current.hasClass("list")
      listHelper.gotoDown(current)
    else if current.is("#navigation")
      list = current.find(".rockets a")
      target = list
        .filter(".focus").removeClass("focus")
        .next().getOrElse(list.last())
        .addClass("focus")

  ## RETURN OBJECT API
  init: ->
    # KEYBOARD NAVIGATION
    $(window).keydown (e)->
      if [13,37,38,39,40].indexOf(e.keyCode) >= 0
        e.preventDefault()
        # Where is focus?
        current = $("#consoleWrapper > .focus").getOrElse($("#navigation"))
        switch e.keyCode
          when 37 then leftkey(current)
          when 38 then upkey(current)
          when 13, 39 then rightkey(current)
          when 40 then downkey(current)
        return false

    # Click on a module to activate it
    $("#consoleWrapper").on "click", "article", (e)->
      $("#consoleWrapper > .focus").removeClass("focus")
      $(this).addClass("focus")
      # key.setScope $(this).data("path")

  update: (modules)->
    pannels = $("#consoleWrapper > .focus")
    if !pannels.length
      $("#consoleWrapper > *:last-child").addClass("focus")
    listHelper.activateAll()

