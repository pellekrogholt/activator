define load: (modules) ->

  d = new $.Deferred()

  modules = [] if !modules

  # Find url from [v]
  plugins = modules.map((i) ->
    "console/" + i.pluginID
  )

  # Load with require
  require plugins, =>
    plugins = [].slice.call(arguments)
    s = []
    $.each(modules,(y,i)->
      #i.plugin = plugins[y++];
      i.module ?= new plugins[y](i)
      s[y] = i
      y++
    )
    # Map loaded modules with [v]
    d.resolve s

  d.promise() # return a promise
