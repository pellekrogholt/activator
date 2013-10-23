define ['css!./actor.css', 'text!./actorDetails.html', 'console/akka/akkaDetailsAtom', './availableCharts', './availableInfoboxes'], (css, template, AkkaDetailsAtom, availableCharts, availableInfoboxes) ->

  class ActorDetails extends AkkaDetailsAtom
    id: undefined
    moduleName: "actorDetails"
    breadcrumb: "Actor Details"
    dataTypes: ["actor"]
    akkaScopes: ["tag", "node", "actorSystem", "dispatcher", "actor"]
    dom: undefined
    availableCharts: availableCharts
    availableInfoboxes: availableInfoboxes
    moduleState:
      metrics: undefined
    moduleStateDefault:
      metrics: [
        [
          {
            type: "chart"
            name: "meanMailboxSize"
          }
          {
            type: "chart"
            name: "timeInMailbox"
          }
          {
            type: "chart"
            name: "latency"
          }
        ]
        [
          {
            type: "infobox"
            name: "actorCounts"
          }
          {
            type: "infobox"
            name: "messageCounts"
          }
          {
            type: "infobox"
            name: "deviations"
          }
        ]
      ]

    constructor: (@parameters) ->
      super(@parameters)
      @id = @parameters.args.before
      @loadState()

    render: ->
      @dom = $(template)
      @renderMetrics()
      @dom

    update: (parameters) ->
      @

    onData: (data) ->
      # Provide module path to metrics
      data.console =
        url: '#' + @parameters.args.pathEncoded.substr(0, @parameters.args.pathEncoded.lastIndexOf('/'))
      @updateMetrics(data)
      @

  ActorDetails
