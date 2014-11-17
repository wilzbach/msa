MenuBuilder = require "../menubuilder"
consenus = require "../../algo/ConsensusCalc"
Seq = require "../../model/Sequence"

module.exports = ExtraMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    @setName("Extras")
    @addNode "Add consensus seq", =>
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
    @addNode "Increase font size", =>
      columnWidth =  @g.zoomer.get("columnWidth")
      nColumnWidth = columnWidth + 5
      @g.zoomer.set "columnWidth",  nColumnWidth
      #@g.zoomer.set "labelWidth", @g.zoomer.get "labelWidth" + 10
      @g.zoomer.set "rowHeight", nColumnWidth
      nFontSize = nColumnWidth * 0.7
      @g.zoomer.set "residueFont", nFontSize
      @g.zoomer.set "labelFontSize",  nFontSize
    @addNode "Decrease font size", =>
      columnWidth =  @g.zoomer.get("columnWidth")
      nColumnWidth = columnWidth - 2
      @g.zoomer.set "columnWidth",  nColumnWidth
      #@g.zoomer.set "labelWidth", @g.zoomer.get "labelWidth" + 10
      @g.zoomer.set "rowHeight", nColumnWidth
      nFontSize = nColumnWidth * 0.6
      @g.zoomer.set "residueFont", nFontSize
      @g.zoomer.set "labelFontSize",  nFontSize

      if @g.zoomer.get("columnWidth") < 8
        @g.zoomer.set "textVisible", false

    @addNode "Bar chart exp scaling", =>
      @g.columns.set "scaling", "exp"
    @addNode "Bar chart linear scaling", =>
      @g.columns.set "scaling", "lin"
    @addNode "Bar chart log scaling", =>
      @g.columns.set "scaling", "log"

    @addNode "Minimized width", =>
      @g.zoomer.set "alignmentWidth", 600
    @addNode "Minimized height", =>
      @g.zoomer.set "alignmentHeight", 120

    @addNode "Jump to a column", =>
      offset = prompt "Column", "20"
      if offset < 0 or offset > @model.getMaxLength() or isNaN(offset)
        alert "invalid column"
        return
      @g.zoomer.setLeftOffset(offset)

    @el.appendChild @buildDOM()
    @
