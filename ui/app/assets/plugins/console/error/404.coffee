define ['text!./404.html', 'atoms/atom'], (template, Atom) ->

  class Error extends Atom
    title: "Error: 404"

    constructor: (@parameters) ->
      noop

    render: ->
      @dom = $(template)

  Error