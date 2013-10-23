define ['css!./akka.css', 'text!./akkaDetails.html', 'console/atoms/detailsAtom', 'console/charts/Charts', './availableCharts', 'console/infoboxes/Infoboxes', './availableInfoboxes'], (css, template, DetailsAtom, Charts, availableCharts, Infoboxes, availableInfoboxes) ->

  class AkkaDetails extends DetailsAtom
    moduleName: "akkaDetails"
    breadcrumb: "Akka Details"
    dataTypes: ["akka"]
    dom: undefined
    availableCharts: availableCharts
    availableInfoboxes: availableInfoboxes
    moduleState:
      metrics: undefined
    moduleStateDefault:
      metrics: [
        [
          {
            type: "infobox"
            name: "scopes"
          }
          {
            type: "infobox"
            name: "systemThroughput"
          }
          {
            type: "infobox"
            name: "mailbox"
          }
          {
            type: "infobox"
            name: "remote"
          }
        ]
        [
          {
            type: "infobox"
            name: "deviations"
          }
          {
            type: "chart"
            name: "throughput"
          }
          {
            type: "chart"
            name: "timeInMailBox"
          }
          {
            type: "chart"
            name: "remoteThroughput"
          }
        ]
      ]

    constructor: (@parameters) ->
      super(@parameters)
      @loadState()
      @

    render: ->
      @dom = $(template)
      @renderMetrics()
      @dom

    update: (parameters) ->
      @

    destroy: ->
      delete @parameters
      delete @dom
      delete @metrics

    onData: (data) ->
      @updateMetrics(data)
      @

    getConnectionParameters: ->
      parameters =
        name: "akka"
        scope: {}

  AkkaDetails
