Fasta = require("biojs-io-fasta")
GFF = require("biojs-io-gff")
xhr = require "xhr"
blobURL = require "blueimp_canvastoblob"
saveAs = require "browser-saveas"
_ = require "underscore"

module.exports = Exporter =

  openInJalview: (url, colorscheme) ->
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
    jalviewUrl += "&colour=" + colorscheme
    window.open jalviewUrl, '_blank'

  publishWeb: (that, cb) ->
    text = Fasta.write that.seqs.toJSON()
    text = encodeURIComponent text
    url = that.u.proxy.corsURL "http://sprunge.biojs.net"
    xhr
      method: "POST"
      body: "sprunge=" + text
      uri: url
      headers:
        "Content-Type": "application/x-www-form-urlencoded"
    , (err,rep,body) ->
      link = body.trim()
      cb(link)

  shareLink: (that, cb) ->
    url = that.g.config.get "importURL"
    msaURL = "http://biojs-msa.org/app/?seq="
    fCB = (link) ->
      fURL = msaURL + link
      if cb
        cb fURL
    unless url
      Exporter.publishWeb that, fCB
    else
      fCB url

  saveAsFile: (that,name) ->
    # limit at about 256k
    text = Fasta.write that.seqs.toJSON()
    blob = new Blob([text], {type : 'text/plain'})
    saveAs blob, name

  saveSelection: (that,name) ->
    selection = that.g.selcol.pluck "seqId"
    console.log selection
    if selection.length > 0
      # filter those seqids
      selection = that.seqs.filter (el) ->
        _.contains selection, el.get "id"
      for i in [0.. selection.length - 1] by 1
        selection[i] = selection[i].toJSON()
    else
      selection = that.seqs.toJSON()
      console.warn "no selection found"
    text = Fasta.write selection
    blob = new Blob([text], {type : 'text/plain'})
    saveAs blob, name

  saveAnnots: (that,name) ->
    features = that.seqs.map (el) ->
      features = el.get "features"
      return if features.length is 0
      seqname = el.get("name")
      features.each (s) ->
        s.set "seqname", seqname
      return features.toJSON()
    features = _.flatten _.compact features
    console.log features
    text = GFF.exportLines features
    blob = new Blob([text], {type : 'text/plain'})
    saveAs blob, name

  saveAsImg: (that,name) ->
      # TODO: this is very ugly
      canvas = that.getView('stage').getView('body').getView('seqblock').el
      if canvas?
        url = canvas.toDataURL('image/png')
        saveAs blobURL(url), name, "image/png"
