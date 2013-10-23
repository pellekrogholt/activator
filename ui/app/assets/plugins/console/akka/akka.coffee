define ['css!./akka.css','text!./akka.html', 'console/atoms/atom', 'console/charts/Charts', './availableCharts', 'console/helpers/list'], (css, template, Atom, Charts, availableCharts, list) ->

  class Akka extends Atom
    moduleName: "akka"
    breadcrumb: "Akka"
    dataTypes: ["akka"]
    dom: undefined
    chart: undefined
    moduleStateDefault:
      chart: "throughput"

    constructor: (@parameters) ->
      @loadState()

    render: ->
      @dom = $(template).clone()
      @list = @dom.find(".listing")

      p = @parameters
      # List
      @list.template @data,
        ".nodes a[href]": (o) -> "#"+p.args.path+"/nodes"
        ".actorSystems a[href]": (o) -> "#"+p.args.path+"/actorSystems"
        ".dispatchers a[href]": (o) -> "#"+p.args.path+"/dispatchers"
        ".actors a[href]": (o) -> "#"+p.args.path+"/actors"
        ".tags a[href]": (o) -> "#"+p.args.path+"/tags"
        ".deviations a[href]": (o) -> "#"+p.args.path+"/deviations"
      @items = @list.children()
      list.navigate @parameters.args.path, @items
      list.activate @items

      @dom

    update: () ->
      list.activate @items

    destroy: ->
      delete @parameters
      delete @dom
      delete @chart

    onData: (data) ->
      @list.template data,
        ".nodes .counter": (o) -> window.format.shortenNumber o.meta.nodeCount
        ".actorSystems .counter": (o) -> window.format.shortenNumber o.meta.actorSystemCount
        ".dispatchers .counter": (o) -> window.format.shortenNumber o.meta.dispatcherCount
        ".actors .counter": (o) -> window.format.shortenNumber o.meta.actorPathCount
        ".deviations .counter": (o) -> window.format.shortenNumber o.deviations.deviationCount
        ".tags .counter": (o) -> window.format.shortenNumber o.meta.tagCount
      @

    getConnectionParameters: ->
      parameters =
        name: @moduleName
        scope: {}

  Akka
