MenuBuilder = require "./menubuilder"
Clustal = require "biojs-io-clustal"
FastaReader = require("biojs-io-fasta").parse
FastaExporter = require("biojs-io-fasta").writer
consenus = require "../algo/ConsensusCalc"
Seq = require "../model/Sequence"

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
      @el.appendChild @_createFileSchemeMenu()
      @el.appendChild @_createColorSchemeMenu()
      @el.appendChild @_createOrderingMenu()
      @el.appendChild @_createExtraMenu()
      @el.appendChild @_createExportMenu()
      @el.appendChild document.createElement("p")

    deleteMenu: ->
      #BioJS.Utils.removeAllChilds(this.menu);
      consoel.log "not implemented"

    _createFileSchemeMenu: ->
      menuFile = new MenuBuilder("Settings")
      menuFile.addNode "Toggle Marker", =>
        @msa.g.vis.set "markers", ! @msa.g.vis.get "markers"
      menuFile.addNode "Toggle Labels", =>
        @msa.g.vis.set "labels", ! @msa.g.vis.get "labels"
      menuFile.addNode "Toggle Sequences", =>
        @msa.g.vis.set "sequences", ! @msa.g.vis.get "sequences"
      menuFile.addNode "Toggle Metacell", =>
        @msa.g.vis.set "metacell", ! @msa.g.vis.get "metacell"

      menuFile.addNode "Toggle mouseover", =>
        @msa.g.config.set "registerMouseEvents", !@msa.g.config.get "registerMouseEvents"

      #menuFile.addNode "Hide Menu", =>
      #@deleteMenu()

      menuFile.buildDOM()

    _createExportMenu: ->
      menuExport = new MenuBuilder("Export")

      menuExport.addNode "Export all", =>
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

      menuFilter.addNode "Hide by Scores", =>

      menuFilter.addNode "Hide by identity", =>

      menuFilter.addNode "Hide gaps", =>

      menuFilter.addNode "Hide %3", =>

        hidden = []
        for index in [0..@msa.seqs.getMaxLength()]
          if index % 3
            hidden.push index
        @msa.g.columns.set "hidden", hidden


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
      menu.buildDOM()

    _createColorSchemeMenu: ->
      menuColor = new MenuBuilder("Color scheme")
      menuColor.addNode "Zappo",(e) =>
        @msa.g.colorscheme.set "scheme","zappo"

      menuColor.addNode "Taylor", =>
        @msa.g.colorscheme.set "scheme","taylor"

      menuColor.addNode "Hydrophobicity", =>
        @msa.g.colorscheme.set "scheme","hydrophobicity"

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
        FastaReader.read url, (seqs) =>
          @msa.g.zoomer.set "textVisible", false
          @msa.seqs.set seqs

      menuImport.addNode "CLUSTAL", =>
        url = prompt "URL (CORS enabled!)",
        "/test/dummy/samples/p53.clustalo.clustal"
        Clustal.read url, (seqs) =>
          @msa.g.zoomer.set "textVisible", false
          @msa.seqs.set seqs

      menuImport.addNode "more", =>
        console.log "yeah it is open source ;-)"

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
