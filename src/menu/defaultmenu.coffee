MenuBuilder = require "./menubuilder"
FastaExporter = require("biojs-io-fasta").writer
saveAs = require "../../external/saver"
Ordering = require "../ordering"

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
        @msa.colorscheme.setScheme "hydrophobicity"
        @msa.stage.redrawStage()

      menuFilter.buildDOM()

    _createColorSchemeMenu: ->
      menuColor = new MenuBuilder("Color scheme")
      menuColor.addNode "Zappo",(e) =>
        @msa.colorscheme.setScheme "zappo"
        @msa.stage.redrawStage()

      menuColor.addNode "Taylor", =>
        @msa.colorscheme.setScheme "taylor"
        @msa.stage.redrawStage()

      menuColor.addNode "Hydrophobicity", =>
        @msa.colorscheme.setScheme "hydrophobicity"
        @msa.stage.redrawStage()

      menuColor.buildDOM()

    _createImportMenu: ->
      menuImport = new MenuBuilder("Import")
      menuImport.addNode "FASTA",(e) =>
        @msa.colorscheme.setScheme "zappo"
        @msa.stage.redrawStage()

      menuImport.addNode "CLUSTAL", =>
        @msa.colorscheme.setScheme "taylor"
        @msa.stage.redrawStage()

      menuImport.addNode "more", =>
        @msa.colorscheme.setScheme "hydrophobicity"
        @msa.stage.redrawStage()

      menuImport.buildDOM()

    _createOrderingMenu: ->
      menuOrdering = new MenuBuilder("Ordering")
      menuOrdering.addNode "ID", =>
        @msa.ordering.setSort Ordering.orderID
        @msa.redrawContainer()

      menuOrdering.addNode "ID Desc", =>
        @msa.ordering.setSort Ordering.orderID
        @msa.ordering.setReverse true
        @msa.redraw()

      menuOrdering.addNode "Label", =>
        @msa.ordering.setSort Ordering.orderName
        @msa.redraw()

      menuOrdering.addNode "Label Desc", =>
        @msa.ordering.setSort Ordering.orderName
        @msa.ordering.setReverse true
        @msa.redraw()

      menuOrdering.addNode "Seq", =>
        @msa.ordering.setSort Ordering.orderName
        @msa.redraw()

      menuOrdering.addNode "Seq Desc", =>
        $(@msa.container).velocity({
            marginTop: 200
        }, 1000);
        @msa.ordering.setSort Ordering.orderSeq
        @msa.ordering.setReverse true
        @msa.redraw()
        window.setTimeout ->
            $(@msa.container).velocity({
                 marginTop: 0
            }, 500);
          , 1000

      menuOrdering.buildDOM()

module.exports = MenuView
