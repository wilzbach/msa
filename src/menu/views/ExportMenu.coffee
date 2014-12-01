MenuBuilder = require "../menubuilder"
saveAs = require "browser-saveas"
FastaExporter = require("biojs-io-fasta").writer
_ = require "underscore"
blobURL = require "blueimp_canvastoblob"
corsURL = require("../../utils/proxy").corsURL
xhr = require "xhr"

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

        if url.indexOf "localhost" or url is "dragimport"
          publishWeb @, (link) =>
            openJalview link, @g.colorscheme.get "scheme"
        else
          openJalview url, @g.colorscheme.get "scheme"

    @addNode "Export sequences", =>
      # limit at about 256k
      text = FastaExporter.export @model.toJSON()
      blob = new Blob([text], {type : 'text/plain'})
      saveAs blob, "all.fasta"

    @addNode "Publish to the web", =>
      publishWeb @, (link) ->
        window.open link, '_blank'

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

openJalview = (url, colorscheme) ->
  jalviewUrl = "http://www.jalview.org/services/launchApp?open=" + url
  jalviewUrl += "&colour=" + colorscheme
  window.open jalviewUrl, '_blank'

publishWeb = (that, cb) ->
  text = FastaExporter.export that.model.toJSON()
  text = encodeURIComponent text
  url = corsURL "http://sprunge.biojs.net", that.g
  xhr
    method: "POST"
    body: "sprunge=" + text
    uri: url
    headers:
      "Content-Type": "application/x-www-form-urlencoded"
  , (err,rep,body) ->
    link = body.trim()
    cb(link)
