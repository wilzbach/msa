view = require("../../bone/view")
sel = require "../../g/selection/Selection"

MenuBuilder = require "../menubuilder"

module.exports = SelectionMenu = view.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    menu = new MenuBuilder("Selection")
    menu.addNode "Find Motif (supports RegEx)", =>
      search = prompt "your search", "D"
      # marks all hits
      search = new RegExp search, "gi"
      selcol = @g.selcol
      newSeli = []
      leftestIndex = origIndex = 100042
      @model.each (seq) ->
        strSeq = seq.get("seq")
        while match = search.exec strSeq
          index = match.index
          args = {xStart: index, xEnd: index + match[0].length - 1, seqId:
            seq.get("id")}
          newSeli.push new sel.possel(args)
          leftestIndex = Math.min index, leftestIndex

      if newSeli.length is 0
        alert "no selection found"
      selcol.reset newSeli

      # safety check + update offset
      leftestIndex = 0 if leftestIndex is origIndex
      @g.zoomer.setLeftOffset leftestIndex

    menu.addNode "Invert columns", =>
      @g.selcol.invertCol [0..@model.getMaxLength()]
    menu.addNode "Invert rows", =>
      @g.selcol.invertRow @model.pluck "id"
    menu.addNode "Reset", =>
      @g.selcol.reset()
    @el.appendChild menu.buildDOM()
    @
