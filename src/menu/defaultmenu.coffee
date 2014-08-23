MenuBuilder = require "./menubuilder"
Clustal = require "biojs-io-clustal"
FastaReader = require("biojs-io-fasta").parse
FastaExporter = require("biojs-io-fasta").writer
consenus = require "../algo/ConsensusCalc"
Seq = require "../model/Sequence"
sel = require "../g/selection/Selection"

saveAs = require "../../external/saver"
_ = require "underscore"

view = require("../bone/view")

MenuView = view.extend

    initialize: (data) ->
      @el.setAttribute "class", "biojs_msa_menubar"
      @msa = data.msa

    render: ->
      @el.appendChild @_createImportMenu()
      @el.appendChild @_createFilterMenu()
      @el.appendChild @_createSelectionMenu()
      @el.appendChild @_createFileSchemeMenu()
      @el.appendChild @_createColorSchemeMenu()
      @el.appendChild @_createOrderingMenu()
      @el.appendChild @_createExtraMenu()
      @el.appendChild @_createExportMenu()
      @el.appendChild @_createHelpMenu()
      @el.appendChild document.createElement("p")

    deleteMenu: ->
      #BioJS.Utils.removeAllChilds(this.menu);
      consoel.log "not implemented"

    _createFileSchemeMenu: ->
      menuFile = new MenuBuilder("Vis. elements")
      menuFile.addNode "Toggle Marker", =>
        @msa.g.vis.set "markers", ! @msa.g.vis.get "markers"
      menuFile.addNode "Toggle Labels", =>
        @msa.g.vis.set "labels", ! @msa.g.vis.get "labels"
      menuFile.addNode "Toggle Sequences", =>
        @msa.g.vis.set "sequences", ! @msa.g.vis.get "sequences"
      menuFile.addNode "Toggle meta info", =>
        @msa.g.vis.set "metacell", ! @msa.g.vis.get "metacell"
      menuFile.addNode "Toggle bars", =>
        @msa.g.vis.set "conserv", ! @msa.g.vis.get "conserv"

      menuFile.addNode "Reset", =>
        @msa.g.vis.set "labels", true
        @msa.g.vis.set "sequences", true
        @msa.g.vis.set "metacell", true
        @msa.g.vis.set "conserv", true

      menuFile.addNode "Toggle mouseover events", =>
        @msa.g.config.set "registerMouseEvents", !@msa.g.config.get "registerMouseEvents"

      #menuFile.addNode "Hide Menu", =>
      #@deleteMenu()

      menuFile.buildDOM()

    _createExportMenu: ->
      menuExport = new MenuBuilder("Export")

      menuExport.addNode "Export sequences", =>
        # limit at about 256k
        text = FastaExporter.export @msa.seqs.toJSON()
        blob = new Blob([text], {type : 'text/plain'})
        saveAs blob, "all.fasta"

      menuExport.addNode "Export selection", =>
        selection = @msa.g.selcol.pluck "seqId"
        if selection?
          # filter those seqids
          selection = @msa.seqs.filter (el) ->
            _.contains selection, el.get "id"
          for i in [0.. selection.length - 1] by 1
            selection[i] = selection[i].toJSON()
        else
          selection = @msa.seqs.toJSON()
          console.log "no selection found"
        text = FastaExporter.export selection
        blob = new Blob([text], {type : 'text/plain'})
        saveAs blob, "selection.fasta"

      menuExport.addNode "Export image (broken)", =>
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
        threshold = prompt "Enter threshold (in percent)", 20
        threshold = threshold / 100
        maxLen = @msa.seqs.getMaxLength()
        hidden = []
        conserv = @msa.g.columns.get("conserv")
        for i in [0.. maxLen - 1]
          console.log conserv[i]
          if conserv[i] < threshold
            hidden.push i
        @msa.g.columns.set "hidden", hidden

      menuFilter.addNode "Hide by Scores (not yet)", =>

      menuFilter.addNode "Hide by identity (not yet)", =>

      menuFilter.addNode "Hide gaps (not yet)", =>

      menuFilter.addNode "Hide %3", =>

        hidden = []
        for index in [0..@msa.seqs.getMaxLength()]
          if index % 3
            hidden.push index
        @msa.g.columns.set "hidden", hidden

      menuFilter.addNode "Reset", =>
        console.log "not working"
      menuFilter.buildDOM()

    _createExtraMenu: ->
      menu = new MenuBuilder("Extras")
      menu.addNode "Add consensus seq", =>
        con = consenus(@msa)
        console.log con
        seq = new Seq
          seq: con
          id: "0c"
          name: "consenus"
        @msa.seqs.add seq
        @msa.seqs.comparator = (seq) ->
          seq.get "id"
        @msa.seqs.sort()
      menu.addNode "Increase font size", =>
        @msa.g.zoomer.set "columnWidth", @msa.g.zoomer.get("columnWidth") + 2
        @msa.g.zoomer.set "labelWidth", @msa.g.zoomer.get("columnWidth") + 5
        @msa.g.zoomer.set "rowHeight", @msa.g.zoomer.get("rowHeight") + 2
        @msa.g.zoomer.set "labelFontSize", @msa.g.zoomer.get("labelFontSize") + 2
      menu.addNode "Decrease font size", =>
        @msa.g.zoomer.set "columnWidth", @msa.g.zoomer.get("columnWidth") - 2
        @msa.g.zoomer.set "rowHeight", @msa.g.zoomer.get("rowHeight") - 2
        @msa.g.zoomer.set "labelFontSize", @msa.g.zoomer.get("labelFontSize") - 2
        if @msa.g.zoomer.get("columnWidth") < 8
          @msa.g.zoomer.set "textVisible", false

      menu.addNode "Bar chart exp scaling", =>
        @msa.g.columns.set "scaling", "exp"
      menu.addNode "Bar chart linear scaling", =>
        @msa.g.columns.set "scaling", "lin"
      menu.addNode "Bar chart log scaling", =>
        @msa.g.columns.set "scaling", "log"
      menu.buildDOM()

    _createHelpMenu: ->
      menu = new MenuBuilder("Help")
      menu.addNode "About the project", =>
        window.open "https://github.com/greenify/biojs-vis-msa"
      menu.addNode "Report issues", =>
        window.open "https://github.com/greenify/biojs-vis-msa/issues"
      menu.addNode "User manual", =>
        window.open "https://github.com/greenify/biojs-vis-msa/wiki"
      menu.buildDOM()

    _createSelectionMenu: ->
      menu = new MenuBuilder("Selection")
      menu.addNode "Find all (supprts RegEx)", =>
        search = prompt "your search (regex support soon)", "D"
        # marks all hits
        search = new RegExp search, "gi"
        selcol = @msa.g.selcol
        newSeli = []
        @msa.seqs.each (seq) ->
          strSeq = seq.get("seq")
          while match = search.exec strSeq
            index = match.index
            args = {xStart: index, xEnd: index + match[0].length - 1, seqId:
              seq.get("id")}
            newSeli.push new sel.possel(args)
        selcol.reset newSeli

      menu.addNode "Select all", =>
        seqs = @msa.seqs.pluck "id"
        seli = []
        for id in seqs
          seli.push new sel.rowsel {seqId: id}
        @msa.g.selcol.reset seli
      menu.addNode "Invert columns", =>
        @msa.g.selcol.invertCol [0..@msa.seqs.getMaxLength()]
      menu.addNode "Invert rows", =>
        @msa.g.selcol.invertRow @msa.seqs.pluck "id"
      menu.addNode "Reset", =>
        @msa.g.selcol.reset()
      menu.buildDOM()

    _createColorSchemeMenu: ->
      menuColor = new MenuBuilder("Color scheme")
      menuColor.addNode "Zappo",(e) =>
        @msa.g.colorscheme.set "scheme","zappo"

      menuColor.addNode "Taylor", =>
        @msa.g.colorscheme.set "scheme","taylor"

      menuColor.addNode "Hydrophobicity", =>
        @msa.g.colorscheme.set "scheme","hydrophobicity"

      menuColor.addNode "No color", =>
        @msa.g.colorscheme.set "scheme","foo"

      menuColor.addNode "Toggle background", =>
        @msa.g.colorscheme.set "colorBackground", !@msa.g.colorscheme.get("colorBackground")

      # greys all lowercase letters
      menuColor.addNode "Grey", =>
        @msa.seqs.each (seq) ->
          residues = seq.get "seq"
          grey = []
          _.each residues, (el, index) ->
            if el is el.toLowerCase()
              grey.push index
          seq.set "grey", grey

      menuColor.addNode "Grey by threshold", =>
        threshold = prompt "Enter threshold (in percent)", 20
        threshold = threshold / 100
        maxLen = @msa.seqs.getMaxLength()
        conserv = @msa.g.columns.get("conserv")
        grey = []
        for i in [0.. maxLen - 1]
          console.log conserv[i]
          if conserv[i] < threshold
            grey.push i
        @msa.seqs.each (seq) ->
          seq.set "grey", grey

      menuColor.addNode "Grey selection", =>
        maxLen = @msa.seqs.getMaxLength()
        @msa.seqs.each (seq) =>
          blocks = @msa.g.selcol.getBlocksForRow(seq.get("id"),maxLen)
          seq.set "grey", blocks

      menuColor.addNode "Reset grey", =>
        @msa.seqs.each (seq) ->
          seq.set "grey", []

      menuColor.buildDOM()

    _createImportMenu: ->
      menuImport = new MenuBuilder("Import")
      menuImport.addNode "FASTA",(e) =>
        url = prompt "URL (CORS enabled!)", "/test/dummy/samples/p53.clustalo.fasta"
        FastaReader.read url, (seqs) =>
          # mass update on zoomer
          zoomer = @msa.g.zoomer.toJSON()
          zoomer.textVisible = false
          zoomer.columnWidth = 4
          zoomer.stepSize = 10
          @msa.seqs.reset []
          @msa.g.zoomer.set zoomer
          @msa.seqs.set seqs

      menuImport.addNode "CLUSTAL", =>
        url = prompt "URL (CORS enabled!)",
        "/test/dummy/samples/p53.clustalo.clustal"
        Clustal.read url, (seqs) =>
          @msa.g.zoomer.set "textVisible", false
          @msa.seqs.set seqs

      menuImport.addNode "add your own Parser", =>
        window.open "https://github.com/biojs/biojs2"

      menuImport.buildDOM()

    _createOrderingMenu: ->
      menuOrdering = new MenuBuilder("Ordering")
      menuOrdering.addNode "ID", =>
        @msa.seqs.comparator = "id"
        @msa.seqs.sort()

      menuOrdering.addNode "ID Desc", =>
        @msa.seqs.comparator = (a, b) ->
          - a.get("id").localeCompare(b.get("id"))
        @msa.seqs.sort()

      menuOrdering.addNode "Label", =>
        @msa.seqs.comparator = "name"
        @msa.seqs.sort()

      menuOrdering.addNode "Label Desc", =>
        @msa.seqs.comparator = (a, b) ->
          - a.get("name").localeCompare(b.get("name"))
        @msa.seqs.sort()

      menuOrdering.addNode "Seq", =>
        @msa.seqs.comparator = "seq"
        @msa.seqs.sort()

      menuOrdering.addNode "Seq Desc", =>
        @msa.seqs.comparator = (a,b) ->
          - a.get("seq").localeCompare(b.get("seq"))
        @msa.seqs.sort()

      menuOrdering.buildDOM()

module.exports = MenuView
