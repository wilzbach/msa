view = require("../../bone/view")
MenuBuilder = require "../menubuilder"

module.exports = HelpMenu = view.extend

  render: ->
    menu = new MenuBuilder("Help")
    menu.addNode "About the project", =>
      window.open "https://github.com/greenify/biojs-vis-msa"
    menu.addNode "Report issues", =>
      window.open "https://github.com/greenify/biojs-vis-msa/issues"
    menu.addNode "User manual", =>
      window.open "https://github.com/greenify/biojs-vis-msa/wiki"
    @el.style.display = "inline-block"
    @el.appendChild menu.buildDOM()
    @
