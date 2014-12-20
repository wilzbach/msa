FileHelper = require "../../utils/file"
MenuBuilder = require "../menubuilder"
xhr = require "xhr"
corsURL = require("../../utils/proxy").corsURL
k = require("koala-js")

module.exports = ImportMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"
    @msa = data.msa

  render: ->
    msa = @msa
    uploader = k.mk "input"
    uploader.type = "file"
    uploader.style.display = "none"
    #uploader.accept
    # http://www.w3schools.com/jsref/prop_fileupload_accept.asp
    # for now we allow multiple files
    uploader.multiple = true
    uploader.addEventListener "change", ->
      files = uploader.files || []
      msa.u.file.importFiles files

    @el.appendChild uploader

    @setName("Import")
    @addNode "URL",(e) =>
      url = prompt "URL",
      "http://rostlab.org/~goldberg/clustalw2-I20140818-215249-0556-53699878-pg.clustalw"
      url = corsURL url, @g
      @g.trigger "import:url", url
      xhr url, (err,resp,body) =>
        if err
          console.log err
        res = @msa.u.file.importFile body
        if res is "error"
          return
        # mass update on zoomer
        #zoomer = @g.zoomer.toJSON()
        ##zoomer.textVisible = false
        ##zoomer.columnWidth = 4
        #zoomer.labelWidth = 200
        #zoomer.boxRectHeight = 2
        #zoomer.boxRectWidth = 2
        #@g.zoomer.set zoomer

    @addNode "From file", =>
      uploader.click()

    @addNode "Drag & Drop", =>
      alert "Yep. Just drag & drop your file"

    @el.appendChild @buildDOM()
    @
