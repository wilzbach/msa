view = require("../../bone/view")
MenuBuilder = require "../menubuilder"
_ = require "underscore"

module.exports = ColorMenu = view.extend

  initialize: (data) ->
    @g = data.g

  render: ->
    menuColor = new MenuBuilder("Color scheme")
    menuColor.addNode "Zappo",(e) =>
      @g.colorscheme.set "scheme","zappo"

    menuColor.addNode "Taylor", =>
      @g.colorscheme.set "scheme","taylor"

    menuColor.addNode "Hydrophobicity", =>
      @g.colorscheme.set "scheme","hydrophobicity"

    menuColor.addNode "No color", =>
      @g.colorscheme.set "scheme","foo"

    menuColor.addNode "Toggle background", =>
      @g.colorscheme.set "colorBackground", !@g.colorscheme.get("colorBackground")

    # greys all lowercase letters
    menuColor.addNode "Grey", =>
      @model.each (seq) ->
        residues = seq.get "seq"
        grey = []
        _.each residues, (el, index) ->
          if el is el.toLowerCase()
            grey.push index
        seq.set "grey", grey

    menuColor.addNode "Grey by threshold", =>
      threshold = prompt "Enter threshold (in percent)", 20
      threshold = threshold / 100
      maxLen = @model.getMaxLength()
      conserv = @g.columns.get("conserv")
      grey = []
      for i in [0.. maxLen - 1]
        console.log conserv[i]
        if conserv[i] < threshold
          grey.push i
      @model.each (seq) ->
        seq.set "grey", grey

    menuColor.addNode "Grey selection", =>
      maxLen = @model.getMaxLength()
      @model.each (seq) =>
        blocks = @g.selcol.getBlocksForRow(seq.get("id"),maxLen)
        seq.set "grey", blocks

    menuColor.addNode "Reset grey", =>
      @model.each (seq) ->
        seq.set "grey", []

    @el = menuColor.buildDOM()
    @
