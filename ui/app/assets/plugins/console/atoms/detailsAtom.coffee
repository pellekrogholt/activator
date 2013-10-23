define ['console/atoms/atom'], (Atom) ->

  templates =
    metricColumn: '<div class="metricColumn"></div>'
    metricBox: '<div class="metricBox"></div>'
    metricTools: '<div class="metricTools"><span class="deleteMetric" data-icon="&#x2715;"></span></div>'
    chart: '<div class="chartBox"><h4 class="title sortableHandle"></h4><div class="chartContainer"></div></div>'
    infobox: '<div class="infobox"><h4 class="title sortableHandle">Infobox</h4><div class="infoboxContainer"></div></div>'

  class DetailsAtom extends Atom

    constructor: (@parameters) ->
      @metrics =
        infobox: {}
        chart: {}

    destroy: ->
      delete @parameters
      delete @dom
      metric.destroy() for metric in @metrics when metric.destroy
      delete @metrics
      @

    renderMetrics: ->
      # Populate metric selection
      @dom.find('.addmetric select')
      .find('optgroup.charts').html(=>
        html = ""
        for chartName, chart of @availableCharts
          html += '<option value="chart-' + chartName + '">' + chart.title + '</option>'
        html
      ).end()
      .find('optgroup.infoboxes').html(=>
        html = ""
        for infoboxName, infobox of @availableInfoboxes
          html += '<option value="infobox-' + infoboxName + '">' + infobox.title + '</option>'
        html
      ).end()
      .on('change', (e) =>
        if $(e.target).val()
          metric = $(e.target).val().split('-')
          @addMetric metric[0], metric[1]
          @saveMetricState()
          $(e.target).val('')
        )

      # Reset metrics
      @dom.find('.resetmetrics button')
      .on('click', (e) =>
        @resetMetrics()
      )

      # Create metrics columns
      $metrics = $('.metricBoxes', @dom).empty().data('columns', @moduleState.metrics.length || 2)
      for metricColumn, col in @moduleState.metrics
        $('<div class="metricColumn"></div>').appendTo($metrics)
        for metric in metricColumn
          @addMetric metric.type, metric.name, col

      # Bind metric tools
      @dom.find('.metricBoxes')
      .on('click', '.metricBox .deleteMetric', (e) =>
         $metricBox = $(e.target).parents('.metricBox')
         @deleteMetric $metricBox.data('type'), $metricBox.data('name'), $metricBox
      )

      # Bind sortables
      @dom.find('.metricBoxes .metricColumn').sortable(
        connectWith: ".metricBoxes .metricColumn"
        containment: ".metricBoxes"
        cursor: "move"
        forcePlaceholderSize: true
        handle: ".sortableHandle"
        revert: 100
        tolerance: "pointer"
        update: (event, ui) =>
          @saveMetricState()
      ).disableSelection()

      @

    addMetric: (type, name, col) ->
      $columns = $('.metricBoxes .metricColumn', @dom)
      # Append to specific column
      if col and $columns.eq(col).length
        $column = $columns.eq(col)
      # Append to shortest column
      else if $columns.length > 0
        $column = $columns.eq(0)
        $column.nextAll().each ->
          if $(@).children().length < $column.children().length
            $column = $(@)
      # Create new column
      else
        $column = $(templates.metricColumn).appendTo($('.metricBoxes', @dom))
      $container = $(templates.metricBox)
        .appendTo($column)
        .data({type: type, name: name})
      if type is "chart" and name of @availableCharts
        $container = $container.html(templates.chart)
        $title = $container.find('.title')
        @metrics[type][name] = @availableCharts[name].create $container.find('.chartContainer')
        $title.text @availableCharts[name].title
      else if type is "infobox" and name of @availableInfoboxes
        $container = $container.html(templates.infobox)
        $title = $container.find('.title')
        $container.addClass(@availableInfoboxes[name].class) if @availableInfoboxes[name].class?
        @metrics[type][name] = @availableInfoboxes[name].create {container: $container.find('.infoboxContainer')}
        $title.text @availableInfoboxes[name].title
      $container.prepend templates.metricTools
      # Disable in selection
      @dom.find('.addmetric select option[value=' + type + '-' + name + ']').attr('disabled', 'disabled')

      @

    deleteMetric: (type, name, container) ->
      if @metrics[type]?[name]?
        @metrics[type][name].destroy() if @metrics[type][name].destroy
        # Remove from metric list
        delete @metrics[type][name]
      # Remove from DOM
      $(container).remove()
      # Activate in selection
      @dom.find('.addmetric select option[value=' + type + '-' + name + ']').removeAttr('disabled')

      @saveMetricState()
      @

    saveMetricState: ->
      metricLayout = []
      $('.metricBoxes .metricColumn', @dom).each ->
        columnLayout = []
        $(@).find('.metricBox').each ->
          columnLayout.push
            name: $(@).data('name')
            type: $(@).data('type')
        metricLayout.push columnLayout
      @moduleState.metrics = metricLayout
      @saveState()
      @

    updateMetrics: (data) ->
      for t, typeMetrics of @metrics
        for n, metric of typeMetrics
          metric.update data
          metric.start() if metric.start
      @

    resetMetrics: ->
      @moduleState.metrics = @moduleStateDefault.metrics
      @dom.replaceWith @render()
      @saveMetricState()
      # hacky-ish, wait for new templates
      setTimeout ->
        $(".wrapper", @dom).smoothScroll()
      ,100
      @

    onTimeUpdateMinutes: (time) ->
      for t, typeMetrics of @metrics
        for n, metric of typeMetrics
          metric.onTimeUpdateMinutes time if metric.onTimeUpdateMinutes
      @

  DetailsAtom