MenuBuilder = require "../menubuilder"
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

    filetypes = "(Fasta, Clustal, GFF, Jalview features, Newick)"

    @setName("Import")
    @addNode "URL",(e) =>
      url = prompt "URL " + filetypes,
      "http://rostlab.org/~goldberg/clustalw2-I20140818-215249-0556-53699878-pg.clustalw"
      @msa.u.file.importURL url, ->
        # mass update on zoomer
        #zoomer = @g.zoomer.toJSON()
        ##zoomer.textVisible = false
        ##zoomer.columnWidth = 4
        #zoomer.boxRectHeight = 2
        #zoomer.boxRectWidth = 2
        #@g.zoomer.set zoomer

    @addNode "From file " + filetypes, =>
      uploader.click()

    @addNode "Drag & Drop", =>
      alert "Yep. Just drag & drop your file " + filetypes

    @el.appendChild @buildDOM()
    @
