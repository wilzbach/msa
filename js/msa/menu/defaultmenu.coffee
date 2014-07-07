define ["cs!msa/menu/menubuilder"], (MenuBuilder) ->
  class DefaultMenu

    constructor: (@divName, @msa) ->
      @menu = document.getElementById @divName
      @menu.className = "biojs_msa_menubar";

    createMenu: ->
      @menu.appendChild @_createFileSchemeMenu()
      @menu.appendChild @_createColorSchemeMenu()
      @menu.appendChild @_createOrderingMenu()
      @menu.appendChild @_createExportMenu()
      @menu.appendChild document.createElement("p")

    deleteMenu: ->
      #BioJS.Utils.removeAllChilds(this.menu);
      return "a"

    _createFileSchemeMenu: ->
      menuFile = new MenuBuilder("Settings")
      menuFile.addNode "Hide Marker", =>
        if @msa.config.visibleElements.ruler is true
          #$(this).children().first().text "Display Marker"
          @msa.config.visibleElements.ruler = false
        else
          #$(this).children().first().text "Hide Marker"
          @msa.visibleElements.ruler = true
        @msa.redrawEntire()

      menuFile.addNode "Hide Labels", =>
        if @msa.config.visibleElements.labels is true
          @msa.config.visibleElements.labels = false
          #$(this).children().first().text "Display Labels"
        else
          @msa.config.visibleElements.labels = true
          #$(this).children().first().text "Hide Labels"
        @msa.redrawEntire()

      menuFile.addNode "Hide Menu", =>
        @deleteMenu()

      menuFile.buildDOM()

    _createExportMenu: ->
      menuExport = new MenuBuilder("Export")

      menuExport.addNode "Export all", =>
        # limit at about 256k
        require ["saveAs", "cs!export/fasta"], (saveAs, FastaExporter) =>
          access = (seq) -> seq.tSeq
          text = FastaExporter.export @msa.seqs,access
          blob = new Blob([text], {type : 'text/plain'})
          saveAs blob, "all.fasta"

      menuExport.addNode "Export selection", =>
        require ["saveAs", "cs!export/fasta"], (saveAs, FastaExporter) =>
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

    _createColorSchemeMenu: ->
      menuColor = new MenuBuilder("Color scheme")
      menuColor.addNode "Zappo",(e) =>
        @msa.colorscheme.setScheme "zappo"
        @msa.stage.recolorStage()

      menuColor.addNode "Taylor", =>
        @msa.colorscheme.setScheme "taylor"
        @msa.stage.recolorStage()

      menuColor.addNode "Hydrophobicity", =>
        @msa.colorscheme.setScheme "hydrophobicity"
        @msa.stage.recolorStage()

      menuColor.buildDOM()

    _createOrderingMenu: ->
      menuOrdering = new MenuBuilder("Ordering")
      menuOrdering.addNode "ID", =>
        @msa.ordering.orderSeqsAfterScheme "numeric"

      menuOrdering.addNode "ID Desc", =>
        @msa.ordering.orderSeqsAfterScheme "reverse-numeric"

      menuOrdering.addNode "Label", =>
        @msa.ordering.orderSeqsAfterScheme "alphabetic"

      menuOrdering.addNode "Label Desc", =>
        @msa.ordering.orderSeqsAfterScheme "reverse-alphabetic"

      menuOrdering.buildDOM()
