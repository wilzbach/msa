MenuBuilder = require "../menubuilder"
saveAs = require "browser-saveas"
FastaExporter = require("biojs-io-fasta").writer
_ = require "underscore"
blobURL = require "blueimp_canvastoblob"

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
        if url.charAt(0) is '.'
          # relative urls
          url = document.URL.substr(0,document.URL.lastIndexOf('/')) + "/" + url

        # check whether this is a local url
        if url.indexOf("http") < 0
          # append host and hope for the best
          host = "http://" + window.location.hostname
          url = host + url

        url = encodeURIComponent url
        jalviewUrl = "http://www.jalview.org/services/launchApp?open=" + url
        window.open jalviewUrl, '_blank'

    @addNode "Export sequences", =>
      # limit at about 256k
      text = FastaExporter.export @model.toJSON()
      blob = new Blob([text], {type : 'text/plain'})
      saveAs blob, "all.fasta"

    @addNode "Export selection", =>
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

    # TODO: use https://github.com/blueimp/JavaScript-Canvas-to-Blob/blob/master/js/canvas-to-blob.js
    @addNode "Export image", =>
      # TODO: this is very ugly
      canvas = @msa.getView('stage').getView('body').getView('seqblock').el
      if canvas?
        url = canvas.toDataURL('image/png')
        saveAs blobURL(url), "biojs-msa.png", "image/png"

      # add octet-stream
      #url = url.replace( /// # cs heregexes
      #/^data[:]image\/(png|jpg|jpeg)[;]/i
      #///, "data:application/octet-stream;")

    @el.appendChild @buildDOM()
    @
