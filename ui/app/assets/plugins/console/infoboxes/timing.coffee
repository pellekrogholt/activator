define ->

  template = """
          <div id="timeline">
              <div class="labels">
                  <div class="durationLabel">Total Duration: <span></span></div>
              </div>
              <div class="viz">
                  <div class="download"></div>
                  <div class="upload"></div>
              </div>
              <div class="labels">
                  <div class="downloadLabel">Download: <span></span></div>
                  <div class="uploadLabel">Upload: <span></span></div>
                  <div class="actionLabel">Action: <span></span></div>
              </div>
          </div>
    """

  class Timing
    @dom: undefined

    constructor: (settings) ->
      settings = $.extend({
        id: undefined
        class: undefined
        title: ""
        container: undefined
        emptyValue: "N/A"
        fields: {}
        updateCallback: undefined
      }, settings)
      @fields = settings.fields
      @container = settings.container
      @emptyValue = settings.emptyValue

      @dom = $(template)
      console.log @, @dom,settings.class
      @dom.attr('id', settings.id) if settings.id?
      @dom.addClass(settings.class) if settings.class?
      $(@container).append @dom if @container?
      @

    append: (@container) ->
      $(@container).append @dom
      @

    remove: ->
      @container.empty()
      @

    update: (data) ->
      # Set up the data with callback if defined
      # data = @updateCallback data if @updateCallback?
      $('#timeline .download').css("width", (data['inputProcessingDuration']/data['duration']*100) + "%")
      $('#timeline .upload').css("width", (data['outputProcessingDuration']/data['duration']*100) + "%")
      $('#timeline .downloadLabel span').text(format.units("milliseconds",(data['inputProcessingDuration']/1000000).toFixed(3)))
      $('#timeline .actionLabel span').text(format.units("milliseconds",(data['actionExecutionDuration']/1000000).toFixed(3)))
      $('#timeline .uploadLabel span').text(format.units("milliseconds",(data['outputProcessingDuration']/1000000).toFixed(3)))
      $('#timeline .durationLabel span').text(format.units("milliseconds",(data['duration']/1000000).toFixed(3)))

  Timing