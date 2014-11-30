Clustal = require "biojs-io-clustal"
FastaReader = require("biojs-io-fasta").parse
MenuBuilder = require "../menubuilder"
corsURL = require("../../utils/proxy").corsURL

module.exports = ImportMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    @setName("Import")
    @addNode "FASTA",(e) =>
      url = prompt "URL", "/test/dummy/samples/p53.clustalo.fasta"
      url = corsURL url, @g
      @g.trigger "import:fasta:url", url
      FastaReader.read url, (seqs) =>
        # mass update on zoomer
        zoomer = @g.zoomer.toJSON()
        #zoomer.textVisible = false
        #zoomer.columnWidth = 4
        zoomer.labelWidth = 200
        zoomer.boxRectHeight = 2
        zoomer.boxRectWidth = 2
        @model.reset []
        @g.zoomer.set zoomer
        @model.reset seqs

    @addNode "CLUSTAL", =>
      url = prompt "URL", "/test/dummy/samples/p53.clustalo.clustal"
      url = corsURL url, @g
      @g.trigger "import:clustal:url", url
      Clustal.read url, (seqs) =>
        zoomer = @g.zoomer.toJSON()
        #zoomer.textVisible = false
        #zoomer.columnWidth = 4
        zoomer.labelWidth = 200
        zoomer.boxRectHeight = 2
        zoomer.boxRectWidth = 2
        @model.reset []
        @g.zoomer.set zoomer
        @model.reset seqs

    @addNode "add your own Parser", =>
      window.open "https://github.com/biojs/biojs2"

    @el.appendChild @buildDOM()
    @
