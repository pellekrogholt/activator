define ['css!./actor.css','text!./actorList.html', 'console/helpers/list','console/akka/akkaAtom'], (css, template, list, AkkaAtom) ->

  viewModes =
    table:
      name: "Table"
      connectionParamName: "actorList"
      templates:
        main: $(template).find("article.table")
      structure: "list"
      filterAnonymous: true
      showFullPath: true
      search: true
      sortBy: ["actorName", "actorPath", "deviation", "maxTimeInMailbox", "maxMailboxSize", "throughput"]
    tree:
      name: "Tree"
      connectionParamName: "actorPaths"
      templates:
        main: $(template).find("article.tree")
      structure: "tree"
      filterAnonymous: true
      showFullPath: false
      search: false
      sortBy: ["actorPath"]
  viewModes.table.templates.item = viewModes.table.templates.main.find(".listing > tr").detach()
  viewModes.tree.templates.item = viewModes.tree.templates.main.find(".listing > li").detach()

  class ActorList extends AkkaAtom
    moduleName: "actors"
    dataTypes: ["actors", "actorPaths"]
    akkaScopes: ["tag", "node", "actorSystem", "dispatcher"]
    breadcrumb: "Actors"
    dom: undefined
    moduleStateDefault:
      filterAnonymous: true
      showFullPath: true
      search: ""
      limit: 50
      sortBy: "actorName"
      viewMode: "table"

    actors: []
    closedActorTrees: []

    constructor: (@parameters)->
      @loadState()
      @init = true
      @

    destroy: ->
      delete @parameters
      delete @moduleState
      delete @dom
      delete @actors
      @

    render: () ->
      @dom = viewModes[@moduleState.viewMode].templates.main.clone()
      @list = @dom.find(".listing")

      # Set saved sorting and filtering
      $('table thead th', @dom).find('span[data-sort-by=' + @moduleState.sortBy + '], span[data-sort-by-alt=' + @moduleState.sortBy + ']').addClass("sortBy")
      $('footer.filters', @dom)
      .find('.limit select').val(@moduleState.limit).end()
      .find('.sortby select').val(@moduleState.sortBy).end()
      .find('.filterAnonymous input').prop("checked", @moduleState.filterAnonymous).end()
      .find('.showFullPath input').prop("checked", @moduleState.showFullPath).end()
      .find('.viewmode select').val(@moduleState.viewMode)

      @checkActiveFilters()

      # Bind UI
      $('table thead', @dom)
      .on('click', 'th span', (e) =>
          @moduleState.sortBy = $(e.target).data("sortBy")
          # Sort by actor name if full path isn't shown
          if @moduleState.sortBy is "actorPath" and !@moduleState.showFullPath
            @moduleState.sortBy = "actorName"
          @saveState()
          @updateConnection()
          $('table thead th span', @dom).removeClass("sortBy")
          $(e.target).addClass("sortBy")
        )
      $('.treeListing', @dom)
      .on('click', '.actor.open > h2 > .handle, .actor.closed > h2 > .handle', (e) =>
        $actor = $(e.target).parent().parent().toggleClass('open closed')
        if $actor.is('.closed')
          @closedActorTrees.push $actor.data('actorPath')
        else
          actorPath = $actor.data('actorPath')
          @closedActorTrees = @closedActorTrees.filter (path) -> path != actorPath
      )
      $('footer.filters', @dom)
      .on('change', '.limit select', (e) =>
        @moduleState.limit = $(e.target).val()
        @saveState()
        @updateConnection()
      )
      .on('change', '.sortby select', (e) =>
        @moduleState.sortBy = $(e.target).val()
        $('table thead th span', @dom).removeClass("sortBy")
        $(e.target).addClass("sortBy")
        @saveState()
      )
      .on('change', '.filterAnonymous input', (e) =>
        @moduleState.filterAnonymous = $(e.target).is(":checked")
        @saveState()
        @checkActiveFilters()
      )
      .on('change', '.showFullPath input', (e) =>
        @moduleState.showFullPath = $(e.target).is(":checked")
        # Sort by actor name if full path isn't shown
        if @moduleState.showFullPath
          @moduleState.sortBy = "actorPath" if @moduleState.sortBy is "actorName"
        else
          @moduleState.sortBy = "actorName" if @moduleState.sortBy is "actorPath"
        @saveState()
        @updateConnection()
        @checkActiveFilters()
      )
      .on('keyup', '.search input', (e) =>
        # Text search filter is not saved to module state
        @moduleState.search = $(e.target).val()
        @checkActiveFilters()
      )
      .on('click', '.search .clear', (e) =>
        $(e.target).siblings('input').val('').trigger('keyup')
        @checkActiveFilters()
      )
      .on('change', '.viewmode select', (e) =>
        viewMode = $(e.target).val()
        if viewMode of viewModes and viewMode isnt @moduleState.viewMode
          @moduleState.viewMode = viewMode
          # Switch connection
          @updateConnection()
          # Change sorting option to match new mode if necessary
          if viewModes[viewMode].sortBy and @moduleState.sortBy not in viewModes[viewMode].sortBy
            @moduleState.sortBy = viewModes[viewMode].sortBy[0]
          @saveState()
          # Replace DOM
          @dom.replaceWith @render()
          $(".wrapper", @dom).smoothScroll()
          $(window).trigger 'resize'
      )

      @dom

    update: () ->
      list.activate @items if @items
      @

    checkActiveFilters: ->
      active = ((@moduleState.search.length > 0) ||
        (!@moduleState.filterAnonymous) ||
        (!@moduleState.showFullPath and viewModes[@moduleState.viewMode].showFullPath))
      $('footer.filters', @dom).toggleClass("activeFilter", active)

    onData: (data) ->
      prevFocus = list.findFocus(@list.children())
      #if !@init then return @ else @init = false
      switch viewModes[@moduleState.viewMode].structure
        # Linear list structure
        when "list"
          # Build actor list
          @actors = []
          for n, a of data.actors.actors
            actor =
              id: a.scope.actorPath
              name: a.scope.actorPath.substr(a.scope.actorPath.lastIndexOf("/") + 1)
              deviations: a.errorCount + a.warningCount + a.deadLetterCount + a.unhandledMessageCount
              throughput: a.totalMessageRate or 0
              maxTimeInMailbox: a.maxTimeInMailbox
              maxTimeInMailboxUnit: a.maxTimeInMailboxUnit
              maxMailboxSize: a.maxMailboxSize
            # Prepend a sorting character to anonymous actor names to sort them last
            actor.nameSort = if actor.name.substr(0, 1) is '$' then ('_' + actor.name) else actor.name
            @actors.push actor
          # Sort & filter list
          if viewModes[@moduleState.viewMode].filterAnonymous and @moduleState.filterAnonymous
            @actors = @actors.filter (a) -> return a.name.substr(0, 1) != "$"
          if viewModes[@moduleState.viewMode].search and @moduleState.search.length > 0
            searchFilter = @moduleState.search.toLowerCase()
            @actors = @actors.filter (a) -> return a.name.toLowerCase().indexOf(searchFilter) != -1
          actorCounts =
            shown: @actors.length
            total: data.actors.total
          # Build actor structure
          @list = @dom.find(".listing")
          settings =
            showFullPath : @moduleState.showFullPath
          basePath = "#" + @parameters.args.pathEncoded
          @list.templateAll viewModes[@moduleState.viewMode].templates.item, @actors,
            "a[href]": (o) -> basePath + "/" + encodeURIComponent o.id
            ".name a[data-hover-text]": (o) -> if !settings.showFullPath then o.id else null
            ".name a": (o) ->
              if settings.showFullPath
                name = o.id.split('/')
                name[name.length - 1] = ('<strong>' + name[name.length - 1] + '</strong>')
                name.join('/<wbr>')
              else
                o.id.substr(o.id.lastIndexOf('/') + 1)
            ".deviation-counter": (o) -> if o.deviations > 0 then o.deviations else ""
            ".throughput a": (o) -> format.units('messages/second', o.throughput, (u, v) -> return format.shorten(v) + ' ' + u)
            ".maxTimeInMailbox a": (o) -> format.units(o.maxTimeInMailboxUnit, o.maxTimeInMailbox, (u, v) -> return format.shorten(v) + ' ' + u)
            ".maxMailboxSize a": "maxMailboxSize"
          @items = @list.children()

        # Tree structure
        when "tree"
          baseUrl = "#" + @parameters.args.pathEncoded + '/'
          html = @renderTree(data.paths.actorPaths.nodes, "", 0, {
            baseUrl: baseUrl,
            filterAnonymous: viewModes[@moduleState.viewMode].filterAnonymous and @moduleState.filterAnonymous
          })
          $('.treeListing', @dom).html html
          # TODO: Fix tree keyboard navigation
          #@list = @dom.find(".treeListing")
          #@items = @list.find('li.actor')
          @items = null
          actorCounts =
            shown: @dom.find('li.actor').length
            total: data.paths.totalActors

      # List
      if @items
        list.navigate @parameters.args.path, @items
        list.activateLink @items, prevFocus
      # Update showing display
      $('footer .showing').find('.itemsShown').text(actorCounts.shown).end().find('.itemsTotal').text(actorCounts.total)

      @

    renderTree: (treeData, path = "", treeLevel = 0, params = {}) ->
      html = ''
      for part in treeData
        # Node
        if part.node?
          html += '<li class="node level_' + treeLevel + '">\n'
          html += '<h2 class="name"><span class="handle"></span>' + part.node + '</h2>\n'
          if part.actorSystems.length > 0
            html += '<ul>' + @renderTree(part.actorSystems, "", treeLevel + 1, params) + '</ul>\n'
          html += '</li>\n'
        # Actor system
        else if part.actorSystem?
          hasChildren = part.paths.length > 0
          # Filter anonymous actors
          if hasChildren and params.filterAnonymous
            part.paths = part.paths.filter (c) -> c.name.substr(0, 1) != '$'
            hasChildren = part.paths.length > 0
          html += '<li class="actorSystem level_' + treeLevel + '">\n'
          html += '<h2 class="name"><span class="handle"></span>' + part.actorSystem + '</h2>\n'
          if hasChildren
            html += '<ul>' + @renderTree(part.paths, 'akka://' + part.actorSystem, treeLevel + 1, params) + '</ul>\n'
          html += '</li>\n'
        # Actors
        else
          # Remove initial slash
          part.name = part.name.substr(1) if part.name.substr(0, 1) is '/'
          actorPath = path + '/' + part.name
          closed = actorPath in @closedActorTrees
          hasChildren = part.children?.length > 0
          # Filter anonymous actors
          if hasChildren and params.filterAnonymous
            part.children = part.children.filter (c) -> c.name.substr(0, 1) != '$'
            hasChildren = part.children?.length > 0
          html += '<li class="actor level_' + treeLevel + (if !hasChildren then " noChildren" else (if closed then " closed" else " open")) + '" data-actor-path="' + actorPath + '">\n'
          html += '<h2 class="name"><span class="handle"></span>'
          if part.name is "user"
            html += part.name
          else
            html += '<a href="' + (params.baseUrl || "") + encodeURIComponent(actorPath) + '" data-hover-text="' + actorPath + '">' + part.name + '</a>'
          html += '</h2>\n'
          if hasChildren
            html += '<ul>' + @renderTree(part.children, actorPath, treeLevel + 1, params) + '</ul>\n'
          html += '</li>\n'
      return html

    getConnectionParameters: () ->
      params = super()
      # Override connection request with viewmode's request
      params.name = viewModes[@moduleState.viewMode].connectionParamName
      params.sortCommand = @moduleState.sortBy
      params.paging =
        offset: 0
        limit: parseInt @moduleState.limit
      params

  ActorList
