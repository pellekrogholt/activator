define ['console/atoms/atom'], (Atom) ->

  class AkkaAtom extends Atom
    akkaScopes: []
    @requiredScopes:
      actorSystem: ["node"]
      dispatcher: ["node", "actorSystem"]
      play: []

    getConnectionParameters: () ->
      params = super()
      params.scope = @getAkkaScope()
      params

    getAkkaScope: () ->
      AkkaAtom.extractScopes(@akkaScopes, @parameters.args.full)

    @extractScopes: (names, args) ->
      if args[0] == "akka"
        AkkaAtom.extractEmbeddedScopes(AkkaAtom.getScopes(names, args), AkkaAtom.requiredScopes)
      else if args[0] == "play"
        "actor": args[4]
      else
        {}

    @getScopes: (names, args) ->
      scope = {}
      for name in names
        scoped = AkkaAtom.getScope(name + "s", args)
        if scoped then scope[name] = scoped
      scope

    @getScope: (name, args) ->
      index = args.indexOf(name)
      if index >= 0 && args.length > (index + 1)
        args[index + 1]

    @extractEmbeddedScopes: (scope, required) ->
      for id, names of required
        if scope[id]
          for name in names
            if not scope[name]
              embedded = scope[id].split("/")
              if embedded.length > 1
                scope[name] = embedded[0]
                scope[id] = embedded[1..].join("/")
      scope

    embeddedScope: (id, scope) ->
      AkkaAtom.createEmbeddedScope(id, @getAkkaScope(), scope, AkkaAtom.requiredScopes)

    @createEmbeddedScope: (id, current, target, required) ->
      embedded = []
      for name in required[id]
        if not current[name]
          embedded.push target[name]
      embedded.push target[id]
      embedded.join("/")

  AkkaAtom
