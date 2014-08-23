view = require("../../bone/view")
view = require("../../bone/view")
Clustal = require "biojs-io-clustal"
FastaReader = require("biojs-io-fasta").parse
MenuBuilder = require "../menubuilder"

module.exports = ImportMenu = view.extend

  initialize: (data) ->
    @g = data.g

  render: ->
    menuImport = new MenuBuilder("Import")
    corsURL = (url) ->
      console.log url
      if url.indexOf('www') >= 0
        url = url.replace "www\.", "www.corsproxy.com/"
      else if url.indexOf('http://') >= 0
        url = url.replace "://", "://www.corsproxy.com/"
      else
        url = "http://www.corsproxy.com/" + url
      url

    menuImport.addNode "FASTA",(e) =>
      url = prompt "URL", "/test/dummy/samples/p53.clustalo.fasta"
      url = corsURL url
      FastaReader.read url, (seqs) =>
        # mass update on zoomer
        zoomer = @g.zoomer.toJSON()
        zoomer.textVisible = false
        zoomer.columnWidth = 4
        zoomer.labelWidth = 200
        zoomer.stepSize = 10
        zoomer.boxRectHeight = 2
        zoomer.boxRectWidth = 2
        @model.reset []
        @g.zoomer.set zoomer
        console.log seqs
        @model.reset seqs

    menuImport.addNode "CLUSTAL", =>
      url = prompt "URL", "/test/dummy/samples/p53.clustalo.clustal"
      url = corsURL url
      Clustal.read url, (seqs) =>
        zoomer = @g.zoomer.toJSON()
        zoomer.textVisible = false
        zoomer.columnWidth = 4
        zoomer.stepSize = 10
        zoomer.labelWidth = 200
        zoomer.boxRectHeight = 2
        zoomer.boxRectWidth = 2
        @model.reset []
        @g.zoomer.set zoomer
        console.log seqs
        @model.reset seqs

    menuImport.addNode "add your own Parser", =>
      window.open "https://github.com/biojs/biojs2"

    @el = menuImport.buildDOM()
    @
