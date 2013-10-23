define ->

  class Infobox
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
      @updateCallback = settings.updateCallback or null

      html = ""
      for field, fieldData of @fields
        classes = []
        classes.push field
        classes.push "hidden" if fieldData.visible? and fieldData.visible is false
        classes = classes.join(" ")
        label = fieldData.label || ""
        value = fieldData.value || ""
        value = fieldData.formatter(value) if value and fieldData.formatter?
        html += "<li class=\"#{classes}\"><span class=\"label\">#{label}</span><span class=\"value\">#{value}</span></li>"
      @dom = $('<ul class="infoboxFields">' + html + '</ul>')
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
      data = @updateCallback data if @updateCallback?
      ### Data structure:
        fieldId1:
          title: string/html content of title container
          value: string/html content of value container
          class: list of classes to set on field
          url: url for field, unset to remove
          hoverText: text for hoverText data attribute on value
        fieldId2:
          ...
      ###
      for field, fieldData of data
        if @fields[field]?
          $field = $('.' + field, @dom)
          # Hide/show
          if fieldData.visible?
            if fieldData.visible then $field.show() else $field.hide()
          # Replace classes on value container
          if fieldData.class?
            $field.removeClass().addClass(field).addClass(fieldData.class)
          # Add or remove link
          if fieldData.url?
            $link = $field.parent 'a'
            if $link.length > 0
              $link.attr 'href', fieldData.url
            else
              $link = $field.wrap("<a></a>").parent('a').attr('href', fieldData.url)
          else
            $link = $field.parent 'a'
            if $link.length > 0
              $field.unwrap()
          # Hover text
          if fieldData.hoverText?
            $field.find('.value').data 'hoverText', fieldData.hoverText
          else
            $field.find('.value').removeData 'hoverText'
          # Update label
          if fieldData.label?
            $field.find('.label').html(fieldData.label)
          # Update value
          if fieldData.value?
            value = if @fields[field].formatter? then @fields[field].formatter(fieldData.value) else fieldData.value
          else
            value = @emptyValue
          $field.find('.value').html value

  Infobox