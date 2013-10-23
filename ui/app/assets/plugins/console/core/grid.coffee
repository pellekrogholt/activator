# The grid handles the views, and pannels (Templating & Positioning)
define ["console/core/header", "console/core/navigation", "console/core/keyboard"], (Header, Navigation, Keyboard) ->

  elements = {} # jQuery objects cached

  align = ->
    $("#consoleWrapper").scrollLeft 99999

  # Responsive grid
  resize = ->
    screen = elements.wrapper.width()
    size = (if screen < 660 then 1 else (if screen < 990 then 2 else (if screen < 1320 then 3 else (if screen < 1650 then 4 else (if screen < 1980 then 5 else 0)))))
    elements.body.attr "data-width", size
    align()

  init: ->
    elements.body = $("body")
    elements.wrapper = $("#consoleWrapper")
    Navigation.init()
    Keyboard.init()
    Header.init()

    $("#consoleWrapper").on animationEnd, -> $(window).trigger("resize")

    # PLACEHOLDER
    $(window).on("resize", resize).trigger "resize"
  
  # Called when data is loaded.
  # Does the rendering
  render: (modules) ->
    d = new $.Deferred()

    modules = modules.map (module) ->
      container = $("#consoleWrapper > *").eq(module.index)
      if container.data("path") is module.args.path
        module.module.update?()
      else
        module.view = $(module.module.render()).data("path", module.args.path).css("z-index", 100 - module.index)
        container = (if !!container.length then container.replaceWith(module.view) else module.view.addClass("fadein").appendTo("#consoleWrapper"))
        $(".wrapper", module.view).smoothScroll()
      module

    modules[modules.length - 1].view.nextAll().remove() if modules[modules.length - 1].view

    Header.update modules
    Keyboard.update modules
    align()

    d.resolve modules
    d.promise()
