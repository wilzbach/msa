MenuBuilder = require "../menubuilder"
Seq = require "../../model/Sequence"
Loader = require "../../utils/loader"
xhr = require "xhr"

module.exports = ExtraMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    @setName("Extras")
    stats = @g.stats
    @addNode "Add consensus seq", =>
      con = stats.consensus()
      seq = new Seq
        seq: con
        id: "0c"
        name: "consenus"
      @model.add seq
      @model.setRef seq
      @model.comparator = (seq) ->
        not seq.get "ref"
      @model.sort()

    @addNode "Load TnT", =>
      # this is a very experimental feature
      # TODO: exclude msa & tnt in the adapter package
      newickStr = ""

      # we require a bunch of dependencies and then load in the tree
      cbs = Loader.joinCb ->
        newick = require "biojs-io-newick"
        newickObj = newick.parse_newick newickStr
        mt = require("msa-tnt")

        sel = new mt.selections()
        treeDiv = document.createElement "div"
        document.body.appendChild treeDiv

        nodes = mt.app
          seqs: @model
          tree: newickObj

        console.log nodes

        t = new mt.adapters.tree
          model: nodes,
          el: treeDiv,
          sel: sel,

      , 3, @

      @g.package.loadPackage "msa-tnt", cbs(1)
      # TODO: my local version is patched
      @g.package.loadPackage "biojs-io-newick", cbs(1)

      newickUrl = "/node_modules/msa-tnt/test/dummy/dummy_newick.newick"
      xhr newickUrl, (err, req, body) ->
        newickStr = body
        cbs()

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
