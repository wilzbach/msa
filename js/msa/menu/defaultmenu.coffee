define ["cs!msa/menu/menubuilder"], (MenuBuilder) ->
  class DefaultMenu

    constructor: (@divName, @msa) ->
      @menu = document.getElementById @divName
      @menu.className = "biojs_msa_menubar";

    createMenu: ->
      @menu.appendChild @_createFileSchemeMenu()
      @menu.appendChild @_createColorSchemeMenu()
      @menu.appendChild @_createOrderingMenu()
      @menu.appendChild document.createElement("p")

    deleteMenu: ->
      #BioJS.Utils.removeAllChilds(this.menu);
      return "a"

    _createFileSchemeMenu: ->
      menuFile = new MenuBuilder("Settings")
      menuFile.addNode "Hide Marker", =>
        if @msa.visibleElements.ruler is true
          #$(this).children().first().text "Display Marker"
          @msa.visibleElements.ruler = false
        else
          #$(this).children().first().text "Hide Marker"
          @msa.visibleElements.ruler = true
        @msa.orderSeqsAfterScheme()

      menuFile.addNode "Hide Labels", =>
        if @msa.visibleElements.labels is true
          @msa.visibleElements.labels = false
          #$(this).children().first().text "Display Labels"
        else
          @msa.visibleElements.labels = true
          #$(this).children().first().text "Hide Labels"
        @msa.redrawEntire()

      menuFile.addNode "Hide Menu", =>
        @deleteMenu()

      menuFile.addNode "Export image", =>
        console.log "trying to render"
        require ["html2canvas"], (HTML2canvas) =>
          HTML2canvas @msa.container, {
            onrendered: (canvas) =>
              console.log "rendered"
              #@msa.container.appendChild canvas
              aLink = document.createElement "a"
              aLink.href = canvas.toDataURL()
              # only for some browsers
              #aLink.href = canvas.toDataURL("image/jpeg")
              aLink.download = "msa.png" # Setup name file
              aLink.href = aLink.href.replace( /// # cs heregexes
              /^data[:]image\/(png|jpg|jpeg)[;]/i
              ///, "data:application/octet-stream;")

              aLink.textContent = "save locally"
              aLink.target = "_blank"
              #window.location.href aLink.href
              @msa.container.appendChild aLink
          }
        , ->
          # on module loading error
          console.log "couldn't load HTML2canvas"


      menuFile.buildDOM()
      menuFile.buildDOM()

    _createColorSchemeMenu: ->
      menuColor = new MenuBuilder("Color scheme")
      menuColor.addNode "Zappo",(e) =>
        @msa.colorscheme.setScheme "zappo"
        @msa.redraw()

      menuColor.addNode "Taylor", =>
        @msa.colorscheme.setScheme "taylor"
        @msa.redraw()

      menuColor.addNode "Hydrophobicity", =>
        @msa.colorscheme.setScheme "hydrophobicity"
        @msa.redraw()

      menuColor.buildDOM()

    _createOrderingMenu: ->
      menuOrdering = new MenuBuilder("Ordering")
      menuOrdering.addNode "ID", =>
        @msa.orderSeqsAfterScheme "numeric"

      menuOrdering.addNode "ID Desc", =>
        @msa.orderSeqsAfterScheme "reverse-numeric"

      menuOrdering.addNode "Label", =>
        @msa.orderSeqsAfterScheme "alphabetic"

      menuOrdering.addNode "Label Desc", =>
        @msa.orderSeqsAfterScheme "reverse-alphabetic"

      menuOrdering.buildDOM()
