MenuBuilder = require "./menubuilder"
Clustal = require "biojs-io-clustal"
FastaReader = require("biojs-io-fasta").parse
FastaExporter = require("biojs-io-fasta").writer
saveAs = require "../../external/saver"
_ = require "underscore"

view = require("../views/view")

MenuView = view.extend

    initialize: (data) ->
      @el.setAttribute "class", "biojs_msa_menubar"
      @msa = data.msa

    render: ->
      @el.appendChild @_createImportMenu()
      @el.appendChild @_createFilterMenu()
      @el.appendChild @_createFileSchemeMenu()
      @el.appendChild @_createColorSchemeMenu()
      @el.appendChild @_createOrderingMenu()
      @el.appendChild @_createExportMenu()
      @el.appendChild document.createElement("p")

    deleteMenu: ->
      #BioJS.Utils.removeAllChilds(this.menu);
      consoel.log "not implemented"

    _createFileSchemeMenu: ->
      menuFile = new MenuBuilder("Settings")
      menuFile.addNode "Hide Marker", =>
        if @msa.config.visibleElements.ruler is true
          #$(this).children().first().text "Display Marker"
          @msa.config.visibleElements.ruler = false
        else
          #$(this).children().first().text "Hide Marker"
          @msa.config.visibleElements.ruler = true
        @msa._draw()

      menuFile.addNode "Hide Labels", =>
        if @msa.config.visibleElements.labels is true
          @msa.config.visibleElements.labels = false
          #$(this).children().first().text "Display Labels"
        else
          @msa.config.visibleElements.labels = true
          #$(this).children().first().text "Hide Labels"
        @msa.redrawContainer()

      menuFile.addNode "Toggle mouseover", =>
        @msa.g.config.set "registerMouseEvents", !@msa.g.config.get "registerMouseEvents"

      #menuFile.addNode "Hide Menu", =>
      #@deleteMenu()

      menuFile.buildDOM()

    _createExportMenu: ->
      menuExport = new MenuBuilder("Export")

      menuExport.addNode "Export all", =>
        # limit at about 256k
        access = (seq) -> seq.tSeq
        text = FastaExporter.export @msa.seqs,access
        blob = new Blob([text], {type : 'text/plain'})
        saveAs blob, "all.fasta"

      menuExport.addNode "Export selection", =>
        selection = @msa.selmanager.getInvolvedSeqs()
        unless selection?
          selection = @msa.seqs
          console.log "no selection found"
        access = (seq) -> seq.tSeq
        text = FastaExporter.export selection,access
        blob = new Blob([text], {type : 'text/plain'})
        saveAs blob, "all.fasta"

      menuExport.addNode "Export image", =>
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

      menuExport.buildDOM()

    _createFilterMenu: ->
      menuFilter = new MenuBuilder("Filter")
      menuFilter.addNode "Hide by threshold",(e) =>
        @msa.colorscheme.setScheme "zappo"
        @msa.stage.redrawStage()

      menuFilter.addNode "Hide by Scores", =>
        @msa.colorscheme.setScheme "taylor"
        @msa.stage.redrawStage()

      menuFilter.addNode "Hide by identity", =>
        @msa.colorscheme.setScheme "taylor"
        @msa.stage.redrawStage()

      menuFilter.addNode "Hide gaps", =>

      menuFilter.addNode "Hide %3", =>

        hidden = []
        for index in [0..@msa.seqs.getMaxLength()]
          if index % 3
            hidden.push index
        @msa.g.columns.set "hidden", hidden


      menuFilter.buildDOM()

    _createColorSchemeMenu: ->
      menuColor = new MenuBuilder("Color scheme")
      menuColor.addNode "Zappo",(e) =>
        @msa.g.colorscheme.set "scheme","zappo"

      menuColor.addNode "Taylor", =>
        @msa.g.colorscheme.set "scheme","taylor"

      menuColor.addNode "Hydrophobicity", =>
        @msa.g.colorscheme.set "scheme","hydrophobicity"

      # greys all lowercase letters
      menuColor.addNode "Grey", =>
        @msa.seqs.each (seq) ->
          residues = seq.get "seq"
          grey = []
          _.each residues, (el, index) ->
            if el is el.toLowerCase()
              grey.push index
          seq.set "grey", grey

      menuColor.addNode "Grey 10-20", =>
        @msa.seqs.each (seq) ->
          residues = seq.get "seq"
          grey = []
          for i in [10..20]
            grey.push i
          seq.set "grey", grey

      menuColor.addNode "Reset grey", =>
        @msa.seqs.each (seq) ->
          seq.set "grey", []

      menuColor.buildDOM()

    _createImportMenu: ->
      menuImport = new MenuBuilder("Import")
      menuImport.addNode "FASTA",(e) =>
        url = prompt "URL (CORS enabled!)", "/test/dummy/samples/p53.clustalo.fasta"
        FastaReader.read url, (seqs) ->
          @msa.g.zoomer.set "textVisible", false
          @msa.seqs.set seqs

      menuImport.addNode "CLUSTAL", =>
        url = prompt "URL (CORS enabled!)",
        "/test/dummy/samples/p53.clustalo.clustal"
        Clustal.read url, (seqs) ->
          @msa.g.zoomer.set "textVisible", false
          @msa.seqs.set seqs

      menuImport.addNode "more", =>
        console.log "yeah it is open source ;-)"

      menuImport.buildDOM()

    _createOrderingMenu: ->
      menuOrdering = new MenuBuilder("Ordering")
      menuOrdering.addNode "ID", =>
        @msa.seqs.comparator = (seq) ->
          seq.get "id"
        @msa.seqs.sort()

      menuOrdering.addNode "ID Desc", =>
        @msa.seqs.comparator = (seq) ->
          - seq.get "id"
        @msa.seqs.sort()

      menuOrdering.addNode "Label", =>
        @msa.seqs.comparator = (seq) ->
          seq.get "name"
        @msa.seqs.sort()

      menuOrdering.addNode "Label Desc", =>
        @msa.seqs.comparator = (a, b) ->
          - a.get("name").localeCompare(b.get("name"))
        @msa.seqs.sort()

      menuOrdering.addNode "Seq", =>
        @msa.seqs.comparator = (seq) ->
          seq.get "seq"
        @msa.seqs.sort()

      menuOrdering.addNode "Seq Desc", =>
        @msa.seqs.comparator = (a,b) ->
          - a.get("seq").localeCompare(b.get("seq"))
        @msa.seqs.sort()

      menuOrdering.buildDOM()

module.exports = MenuView
