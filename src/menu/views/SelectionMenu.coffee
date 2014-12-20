MenuBuilder = require "../menubuilder"

module.exports = SelectionMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    @setName("Selection")
    @addNode "Find Motif (supports RegEx)", =>
      search = prompt "your search", "D"
      @g.user.set "searchText", search

    @addNode "Invert columns", =>
      @g.selcol.invertCol [0..@model.getMaxLength()]
    @addNode "Invert rows", =>
      @g.selcol.invertRow @model.pluck "id"
    @addNode "Reset", =>
      @g.selcol.reset()
    @el.appendChild @buildDOM()
    @
