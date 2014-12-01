FileHelper = require "../../utils/file"
MenuBuilder = require "../menubuilder"
xhr = require "xhr"
corsURL = require("../../utils/proxy").corsURL

module.exports = ImportMenu = MenuBuilder.extend

  initialize: (data) ->
    @g = data.g
    @el.style.display = "inline-block"

  render: ->
    @setName("Import")
    @addNode "URL",(e) =>
      url = prompt "URL",
      "http://rostlab.org/~goldberg/clustalw2-I20140818-215249-0556-53699878-pg.clustalw"
      url = corsURL url, @g
      @g.trigger "import:url", url
      xhr url, (err,resp,body) =>
        if err
          console.log err
        seqs = FileHelper.parseText body
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

    @addNode "Drag & Drop", =>
      alert "Yep. Just drag & drop your file"

    @addNode "add your own Parser", =>
      window.open "https://github.com/biojs/biojs"

    @el.appendChild @buildDOM()
    @
