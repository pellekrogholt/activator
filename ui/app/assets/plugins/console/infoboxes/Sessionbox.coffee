define ['./Infobox'], (Infobox) ->

  class SessionBox extends Infobox

    update: (data) ->
      if @done then return
      @done = true
      @dom.empty()
      $.each data.invocationInfo.session, (k,v)=>
        item = $("<li/>").appendTo(@dom)
        $('<a class="label"/>')
          .html(k)
          .appendTo(item)
        $('<a class="value"/>')
          .html(v)
          .appendTo(item)

  SessionBox