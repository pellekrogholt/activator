define ['css!./flow.css','text!./flow.html', 'console/atoms/atom', 'console/helpers/list'], (css, template, Atom, list) ->

  class Flow extends Atom
    moduleName: "play"
    dom: undefined

    constructor: (@parameters) ->

    render: ->
      @dom = $(template).clone()

      @dom

    update: () ->
      # list.activate @items

    destroy: ->

    onData: (data) ->

    getConnectionParameters: ->

  Flow
