MenuBuilder = require "../menubuilder"

module.exports = DebugMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    @setName("Debug")

    @addNode "Get the code", =>
      window.open "https://github.com/greenify/biojs-vis-msa"

    @addNode "Toggle mouseover events", =>
      @g.config.set "registerMouseHover", !@g.config.get "registerMouseHover"

    @el.appendChild @buildDOM()
    @
