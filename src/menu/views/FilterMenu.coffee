view = require("../../bone/view")
MenuBuilder = require "../menubuilder"

module.exports = FilterMenu = view.extend

  initialize: (data) ->
    @g = data.g

  render: ->
    menuFilter = new MenuBuilder("Filter")
    menuFilter.addNode "Hide by threshold",(e) =>
      threshold = prompt "Enter threshold (in percent)", 20
      threshold = threshold / 100
      maxLen = @model.getMaxLength()
      hidden = []
      conserv = @g.columns.get("conserv")
      for i in [0.. maxLen - 1]
        console.log conserv[i]
        if conserv[i] < threshold
          hidden.push i
      @g.columns.set "hidden", hidden

    menuFilter.addNode "Hide by Scores (not yet)", =>

    menuFilter.addNode "Hide by identity (not yet)", =>

    menuFilter.addNode "Hide selection", =>
      hiddenOld = @g.columns.get "hidden"
      hidden = hiddenOld.concat @g.selcol.getAllColumnBlocks @model.getMaxLength()
      @g.selcol.reset []
      @g.columns.set "hidden", hidden

    menuFilter.addNode "Hide gaps (not yet)", =>

    menuFilter.addNode "Hide one third (%3)", =>

      hidden = []
      for index in [0..@model.getMaxLength()]
        if index % 3
          hidden.push index
      @g.columns.set "hidden", hidden

    menuFilter.addNode "Reset", =>
      @g.columns.set "hidden", []

    @el = menuFilter.buildDOM()
    @
