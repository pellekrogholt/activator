define ['./Infobox'], (Infobox) ->

  class AkkaBox extends Infobox

    update: (data) ->
      if @done then return
      @done = true
      if data.actorInfo.length == 0
        # TODO
        @container.parent().parent().remove()
        return
      base = window.location.hash.split("/").slice(0,4).join("/")
      @dom.empty()
      for i in data.actorInfo
        item = $("<li/>").appendTo(@dom)
        $('<a class="label"/>')
          .html(i.actorPath)
          .attr("href", base + "/" + encodeURIComponent(i.actorPath))
          .appendTo(item)

  AkkaBox