define ['css!./actor.css','text!./actor.html','console/akka/akkaAtom', 'console/charts/CommonCharts', 'console/helpers/list'], (css, template, AkkaAtom, CommonCharts, list) ->

  class Actor extends AkkaAtom
    id: undefined
    moduleName: "actor"
    dataTypes: ["actor"]
    akkaScopes: ["tag", "node", "actorSystem", "dispatcher", "actor"]
    dom: undefined
    chart: undefined

    constructor: (@parameters) ->
      @id = @parameters.args.id
      @

    render: ->
      @dom = $(template).clone()
      @list = @dom.find(".listing")
      # Title
      @dom.find('header .title').text @id.substr @id.lastIndexOf("/")+1
      # Chart
      @chart = CommonCharts.throughput.create $('.chartContainer', @dom)
      # List
      @list.find('.details a').attr 'href', '#' + @parameters.args.pathEncoded + "/details"
      actor =
        path: @parameters.args.full
        parent: @getParentActor()
      debug && console.log "actor parent : ", actor
      if actor.parent
        @list.template actor,
          ".parent a[href]": (o) -> "#" + o.path.slice(0, -1).map(encodeURIComponent).join("/") + "/" + encodeURIComponent(o.parent)
          ".parent a": (o) -> o.parent.substr(o.parent.lastIndexOf("/")+1)
      else
        @list.find('.parent').remove()
      @items = @list.children()
      list.navigate @parameters.args.path, @items
      list.activate @items
      @dom

    update: () ->
      list.activate @items
      @

    destroy: ->
      delete @parameters
      delete @dom
      @chart.destroy()
      delete @chart
      @

    onData: (data) ->
      # Chart
      @chart.update(data).start() if @chart
      # List
      path = "#" + @parameters.args.pathEncoded
      @list.template data,
        ".deviations a[href]": (o) -> path + "/deviations"
        ".deviations .counter": (o) -> window.format.shortenNumber o.deviations.deviationCount
      @

    getParentActor: ->
      actorPath = @id.replace("akka://", "").split("/")
      return if actorPath.length > 3 then ("akka://" + actorPath.slice(0, -1).join("/")) else false

    onTimeUpdateMinutes: (time) -> @chart.onTimeUpdateMinutes time if @chart.onTimeUpdateMinutes

  Actor
