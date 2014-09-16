Clustal = require "biojs-io-clustal"
FastaReader = require("biojs-io-fasta").parse
MenuBuilder = require "../menubuilder"

module.exports = ImportMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    @setName("Import")
    corsURL = (url) =>
      # do not filter on localhost
      return url if document.URL.indexOf('localhost') >= 0 and url[0] is "/"

      # remove www + http
      url = url.replace "www\.", ""
      url = url.replace "http://", ""

      # prepend proxy
      url = @g.config.get('importProxy') + url
      url

    @addNode "FASTA",(e) =>
      url = prompt "URL", "/test/dummy/samples/p53.clustalo.fasta"
      url = corsURL url
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
        @g.columns.calcConservation @model

    @addNode "CLUSTAL", =>
      url = prompt "URL", "/test/dummy/samples/p53.clustalo.clustal"
      url = corsURL url
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
        @g.columns.calcConservation @model

    @addNode "add your own Parser", =>
      window.open "https://github.com/biojs/biojs2"

    @el.appendChild @buildDOM()
    @
