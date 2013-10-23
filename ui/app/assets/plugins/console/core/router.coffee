define ->

  # Decomposed url in an array
  breadcrumb = []

  # Routes are nested:
  # " /projects/:id/code/ " would call each related route
  # And each route is associated with a requirejs plugin
  # Example:
  #  {
  #      'foo':                 [ "foo/foo" , {
  #          'bar':             [ "foo/bar" ],
  #          ':id':             [ "foo/foobar" ]
  #      }]
  #  }

  deviations = [
    "deviations/deviationList",
    ":id": ["deviations/deviation"]
  ]

  actor = ["actors/actor" # Actor ID
    "details": ["actors/actorDetails"],
    "flow": ["actors/flow"]
    "deviations": deviations
  ]

  actors = [
    "actors/actorList",
    ":id": actor
  ]

  actorTree = [
    "actors/actorTree",
    ":id": actor
  ]

  dispatchers = [
      "dispatchers/dispatcherList",
      ":id": ["dispatchers/dispatcher",
        "actors": actors
        "actorTree": actorTree
        "deviations": deviations
        "details": ["dispatchers/dispatcherDetails"]
      ]
    ]

  actorSystems = [
      "actorSystems/actorSystemList",
      ":id": ["actorSystems/actorSystem",
        "dispatchers": dispatchers
        "actors": actors
        "actorTree": actorTree
        "deviations": deviations
        "details": ["actorSystems/actorSystemDetails"]
      ]
    ]

  nodes = [
      "nodes/nodeList",
      "metrics": ["nodes/nodeMetrics"]
      ":id": ["nodes/node",
        "actorSystems": actorSystems,
        "dispatchers": dispatchers,
        "actors": actors,
        "actorTree": actorTree
        "deviations": deviations
        "details": ["nodes/nodeDetails"]
      ]
    ]

  tags = [
    "tags/tagList",
    ":id": ["tags/tag",
      "nodes": nodes,
      "actorSystems": actorSystems,
      "dispatchers": dispatchers,
      "actors": actors,
      "deviations": deviations,
      "details": ["tags/tagDetails"]
    ]
  ]

  akka = [
    "akka/akka",
    "nodes": nodes
    "actorSystems": actorSystems
    "dispatchers": dispatchers
    "actors": actors
    "deviations": deviations
    "tags": tags
    "details": ["akka/akkaDetails"]
  ]

  play = [
    "play/play",
    "details": ["play/details"]
    "requests": [
      "play/requests",
      ":id": [
        "play/requestMonitor",
        ":id": [
          "play/requestView",
          ":id": actor
        ]
      ]
    ]
  ]

  console = [
    "akka/akka",
    "actors": actors
  ]

  routes =
    "console": console
    "akka": akka
    "play": play
    "help": ["help/help"]

  # From the breadcrumb, checks route synthax and get module
  # Let's comment this, it's all about conventions.
  match = (bc, routes, modules, loaded, old) ->
    rest = bc.slice(1)
    url = bc.shift()
    i = modules.length
    args =
      id: url
      full: breadcrumb
      rest: rest
      before: modules[i - 1]?.url
      path: (if i > 0 then modules[i - 1].args.path + "/" + url else url)
      pathEncoded: (if i > 0 then (modules[i - 1].args.pathEncoded + "/" + encodeURIComponent(url)) else encodeURIComponent(url))
    #
    args.type = url

    # If no url, then it's the index
    url = "index" if not url
    # Get object from the routes definitions
    _route = routes[url] or routes[":id"]

    # if module is already loaded
    if loaded[i]?.args.path is args.path
      modules[i] = loaded[i]
      modules[i].args = args
      # Remove module from old module list
      old = old.filter (m) -> return args.path != m

    # Module is not loaded, but we have a route
    else if _route
      # Get rid of the loaded items left
      if i > 0
        loaded = loaded.slice(0,i)
      # Define the module nutshell object
      modules[i] =
        pluginID: _route[0]
        index: i
        # recompose the url from previous object, #weird
        url: url
        args: args
      # Remove module from old module list
      old = old.filter (m) -> return args.path != m

    # Ooops...
    else
      bc = [] # next arguments are not valid anymore
      modules[i] =
        args: args
        url: "404"
        pluginID: "error/404"
        index: i

    # if there are other url arguments
    if _route?[1] and bc.length
      # then continue matching
      modules = match(bc, _route[1], modules, loaded, old)
    else
      # Remove old unused modules
      m.module.destroy() for m in loaded when m.args.path in old

      modules

  # returns an Array of matched modules
  parse: (loadedModules) -> # note the ":"

    url = window.location.hash
    # TODO: Get default path from global settings
    home = ""
    # if not url then window.location.hash = home

    # Split full path in modules
    # Use location.href.split("#")[1] instead of window.location.hash because Firefox automatically decodes the latter
    breadcrumb = /^#?\/?(.+)$/.exec(location.href.split("#")[1] || home)[1].split("/")

    if breadcrumb[0] && breadcrumb[0] == "console"

      # Decode urlencoded breadcrumbs
      breadcrumb = breadcrumb.map (b) -> decodeURIComponent b

      # List old module paths for deletion of unused modules
      oldModules = (m.args.path for m in loadedModules) if loadedModules

      # Check if modules are loaded, or retrieve module object and return list
      match(breadcrumb.slice(0), routes, [], loadedModules, oldModules)
