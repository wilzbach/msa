MenuBuilder = require "../menubuilder"

module.exports = DebugMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    @setName("Debug")

    @addNode "Get the code", =>
      window.open "https://github.com/greenify/msa"

    @addNode "Toggle mouseover events", =>
      @g.config.set "registerMouseHover", !@g.config.get "registerMouseHover"
      @g.onAll ->
        console.log arguments

    @addNode "Minimized width", =>
      @g.zoomer.set "alignmentWidth", 600
    @addNode "Minimized height", =>
      @g.zoomer.set "alignmentHeight", 120

    @el.appendChild @buildDOM()
    @
