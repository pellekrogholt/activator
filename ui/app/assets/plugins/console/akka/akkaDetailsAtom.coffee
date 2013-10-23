define ['console/atoms/detailsAtom', 'console/akka/akkaAtom'], (DetailsAtom, AkkaAtom) ->

  class AkkaDetailsAtom extends DetailsAtom
    akkaScopes: []

    getConnectionParameters: () ->
      params = super()
      params.scope = @getAkkaScope()
      params

    getAkkaScope: () ->
      AkkaAtom.extractScopes(@akkaScopes, @parameters.args.full)

  AkkaDetailsAtom
