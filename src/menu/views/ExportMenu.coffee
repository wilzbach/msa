view = require("../../bone/view")
MenuBuilder = require "../menubuilder"
saveAs = require "../../../external/saver"
FastaExporter = require("biojs-io-fasta").writer
_ = require "underscore"

module.exports = ExportMenu = view.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    menuExport = new MenuBuilder("Export")

    menuExport.addNode "Export sequences", =>
      # limit at about 256k
      text = FastaExporter.export @model.toJSON()
      blob = new Blob([text], {type : 'text/plain'})
      saveAs blob, "all.fasta"

    menuExport.addNode "Export selection", =>
      selection = @g.selcol.pluck "seqId"
      if selection?
        # filter those seqids
        selection = @model.filter (el) ->
          _.contains selection, el.get "id"
        for i in [0.. selection.length - 1] by 1
          selection[i] = selection[i].toJSON()
      else
        selection = @model.toJSON()
        console.log "no selection found"
      text = FastaExporter.export selection
      blob = new Blob([text], {type : 'text/plain'})
      saveAs blob, "selection.fasta"

    menuExport.addNode "Export image (broken)", =>
      console.log "trying to render"
      require ["html2canvas", "saveAs"], (HTML2canvas, saveAs) =>
        HTML2canvas @msa.container, {
          onrendered: (canvas) =>
            #url = canvas.toDataURL()
            # only for some browsers
            #url = canvas.toDataURL("image/jpeg")
            #url = url.replace( /// # cs heregexes
            #/^data[:]image\/(png|jpg|jpeg)[;]/i
            #///, "data:application/octet-stream;")

            canvas.toBlob( (blob) ->
              saveAs blob, "biojs-msa.png"
            , "image/png")

            #win = window.open url, '_blank'
        }
      , ->
        # on module loading error
        console.log "couldn't load HTML2canvas"

    @el.appendChild menuExport.buildDOM()
    @
