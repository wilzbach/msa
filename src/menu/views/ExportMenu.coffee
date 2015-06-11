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

    @addNode "Share view (URL) ↪", =>
      Exporter.shareLink @msa, (link) ->
        window.open link, '_blank'

    @addNode "View in Jalview", =>
      url = @g.config.get('url')
      unless url?
        alert "Sequence weren't imported via an URL"
      else
        if url.indexOf "localhost" or url is "dragimport"
          Exporter.publishWeb @msa, (link) =>
            Exporter.openInJalview link, @g.colorscheme.get "scheme"
        else
          Exporter.openInJalview url, @g.colorscheme.get "scheme"

    @addNode "Export alignment (FASTA)", =>
      Exporter.saveAsFile @msa, "all.fasta"

    @addNode "Export alignment (URL)", =>
      Exporter.publishWeb @msa, (link) ->
        window.open link, '_blank'

    @addNode "Export selected sequences (FASTA)", =>
      Exporter.saveSelection @msa, "selection.fasta"

    @addNode "Export features (GFF)", =>
      Exporter.saveAnnots @msa, "features.gff3"

    @addNode "Export MSA image (PNG)", =>
      Exporter.saveAsImg @msa, "biojs-msa.png"

    @el.appendChild @buildDOM()
    @
