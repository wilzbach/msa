MenuBuilder = require "../menubuilder"
Seq = require "../../model/Sequence"
Loader = require "../../utils/loader"
xhr = require "xhr"

module.exports = ExtraMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"
    @msa = data.msa

  render: ->
    @setName("Extras")
    stats = @g.stats
    msa = @msa
    @addNode "Add consensus seq", =>
      con = stats.consensus()
      seq = new Seq
        seq: con
        id: "0c"
        name: "Consenus"
      @model.add seq
      @model.setRef seq
      @model.comparator = (seq) ->
        not seq.get "ref"
      @model.sort()

    #@addNode "Calc Tree", ->
      ## this is a very experimental feature
      ## TODO: exclude msa & tnt in the adapter package
      #newickStr = ""

      #cbs = Loader.joinCb ->
        #msa.u.tree.showTree nwkData
      #, 2, @

      #msa.u.tree.loadTree cbs
      ## load fake tree
      #nwkData =
        #name: "root",
        #children: [
          #name: "c1",
          #branch_length: 4
          #children: msa.seqs.filter (f,i) ->  i % 2 is 0
        #,
          #name: "c2",
          #children: msa.seqs.filter (f,i) ->  i % 2 is 1
          #branch_length: 4
        #]
      #msa.seqs.each (s) ->
        #s.set "branch_length", 2
      #cbs()

    @addNode "Increase font size", =>
      columnWidth =  @g.zoomer.get("columnWidth")
      nColumnWidth = columnWidth + 5
      @g.zoomer.set "columnWidth",  nColumnWidth
      @g.zoomer.set "rowHeight", nColumnWidth
      nFontSize = nColumnWidth * 0.7
      @g.zoomer.set "residueFont", nFontSize
      @g.zoomer.set "labelFontSize",  nFontSize
    @addNode "Decrease font size", =>
      columnWidth =  @g.zoomer.get("columnWidth")
      nColumnWidth = columnWidth - 2
      @g.zoomer.set "columnWidth",  nColumnWidth
      @g.zoomer.set "rowHeight", nColumnWidth
      nFontSize = nColumnWidth * 0.6
      @g.zoomer.set "residueFont", nFontSize
      @g.zoomer.set "labelFontSize",  nFontSize

      if @g.zoomer.get("columnWidth") < 8
        @g.zoomer.set "textVisible", false


    @addNode "Jump to a column", =>
      offset = prompt "Column", "20"
      if offset < 0 or offset > @model.getMaxLength() or isNaN(offset)
        alert "invalid column"
        return
      @g.zoomer.setLeftOffset(offset)

    @el.appendChild @buildDOM()
    @
