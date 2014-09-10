MenuBuilder = require "../menubuilder"
consenus = require "../../algo/ConsensusCalc"
Seq = require "../../model/Sequence"
view = require("../../bone/view")

module.exports = ExtraMenu = view.extend

  initialize: (data) ->
    @g = data.g

  render: ->
    menu = new MenuBuilder("Extras")
    menu.addNode "Add consensus seq", =>
      con = consenus(@model)
      console.log con
      seq = new Seq
        seq: con
        id: "0c"
        name: "consenus"
      @model.add seq
      @model.comparator = (seq) ->
        seq.get "id"
      @model.sort()
    menu.addNode "Increase font size", =>
      @g.zoomer.set "columnWidth", @g.zoomer.get("columnWidth") + 2
      @g.zoomer.set "labelWidth", @g.zoomer.get("columnWidth") + 5
      @g.zoomer.set "rowHeight", @g.zoomer.get("rowHeight") + 2
      @g.zoomer.set "labelFontSize", @g.zoomer.get("labelFontSize") + 2
    menu.addNode "Decrease font size", =>
      @g.zoomer.set "columnWidth", @g.zoomer.get("columnWidth") - 2
      @g.zoomer.set "rowHeight", @g.zoomer.get("rowHeight") - 2
      @g.zoomer.set "labelFontSize", @g.zoomer.get("labelFontSize") - 2
      if @g.zoomer.get("columnWidth") < 8
        @g.zoomer.set "textVisible", false

    menu.addNode "Bar chart exp scaling", =>
      @g.columns.set "scaling", "exp"
    menu.addNode "Bar chart linear scaling", =>
      @g.columns.set "scaling", "lin"
    menu.addNode "Bar chart log scaling", =>
      @g.columns.set "scaling", "log"

    menu.addNode "Minimized width", =>
      @g.zoomer.set "alignmentWidth", 600
    menu.addNode "Minimized height", =>
      @g.zoomer.set "alignmentHeight", 120

    menu.addNode "Jump to a column", =>
      offset = prompt "Column", "20"
      @g.zoomer.setLeftOffset(offset)

    @el = menu.buildDOM()
    @
