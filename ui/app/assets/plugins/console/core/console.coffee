# Sort of MVC (Module, Grid, Router)
define ["console/core/module", "console/core/grid", "console/core/router", "console/core/connection", "console/core/timemachine"], (Module, Grid, Router, Connection, Timemachine) ->

  loadedModules = []

  init = ->
    # Start connection
    Connection
      .init(Timemachine.getTime())
      .registerRecieveCallback(Timemachine.onData)
      .open(consoleWsUrl, ->
        # Model for the whole app view
        # All the magic here.
        $(window).on("hashchange", ->
          loadedModules = Router.parse(loadedModules)
          Module.load(loadedModules)
            .pipe(Grid.render)
            .pipe(Connection.updateModules)
        ).trigger "hashchange"
      )

  # wait for dom to load first
  $ ->
    Grid.init()
    init()
