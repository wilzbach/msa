MenuBuilder = require "../menubuilder"

module.exports = HelpMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g

  render: ->
    @setName("Help")
    @addNode "About the project", =>
      window.open "https://github.com/greenify/msa"
    @addNode "Report issues", =>
      window.open "https://github.com/greenify/msa/issues"
    @addNode "User manual", =>
      window.open "https://github.com/greenify/msa/wiki"
    @el.style.display = "inline-block"
    @el.appendChild @buildDOM()
    @
