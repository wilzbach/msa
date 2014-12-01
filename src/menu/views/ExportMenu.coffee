MenuBuilder = require "../menubuilder"
FastaExporter = require("biojs-io-fasta").writer
_ = require "underscore"
Exporter = require "../../utils/export"

module.exports = ExportMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @msa = data.msa
    @el.style.display = "inline-block"

  render: ->
    @setName("Export")

    @addNode "View in Jalview", =>
      url = @g.config.get('url')
      unless url?
        alert "Sequence weren't imported via an URL"
      else
        if url.indexOf "localhost" or url is "dragimport"
          Exporter.publishWeb @, (link) =>
            Exporter.openInJalview link, @g.colorscheme.get "scheme"
        else
          Exporter.openInJalview url, @g.colorscheme.get "scheme"

    @addNode "Publish to the web", =>
      Exporter.publishWeb @, (link) ->
        window.open link, '_blank'

    @addNode "Export sequences", =>
      Exporter.saveAsFile @msa, "all.fasta"

    @addNode "Export selection", =>
      Exporter.saveSelection @msa, "selection.fasta"

    @addNode "Export image", =>
      Exporter.saveAsImg @msa, "biojs-msa.png"

    @el.appendChild @buildDOM()
    @
