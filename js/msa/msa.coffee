define ["cs!msa/colorator", "./sequence", "cs!msa/ordering", "./utils",
    "./row",  "cs!msa/eventhandler", "./selection/main"
], (Colorator, Sequence,
      Ordering, Utils, Row, Eventhandler, selection) ->

  class MSA

    constructor: (divName, config) ->
      @columnWidth = 20
      @columnHeight = 20
      @columnSpacing = 5

      # how much space for the labels?
      @seqOffset = 140
      @labelFontsize = 13

      @colorscheme = new Colorator()
      @ordering = new Ordering()

      @events = new Eventhandler(@log)
      @selmanager = new selection.SelectionManager(@, @events)

      # support for only one argument
      if not config?
        config = {}

      @visibleElements = {
        labels: true, sequences: true, menubar: true, ruler: true
      }


      # an Array of BioJS.MSA.Row
      @seqs = []


      # create menubar  + canvas
      @console = document.getElementById "console"
      @container = document.getElementById divName

      # BEGIN : CONSTRUCTOR
      if config.registerMoveOvers?
        @registerMoveOvers = true
        @container.addEventListener 'mouseout', =>
          @selmanager.cleanup()
      else
        @registerMoveOvers = false

      @stageID =  String.fromCharCode(65 + Math.floor(Math.random() * 26))
      @globalID = 'biojs_msa_' + @stageID

      @stage = document.createElement("div")
      @stage.setAttribute("id","#{@globalID}_canvas")
      @stage.setAttribute("class", "biojs_msa_stage")
      #@container.appendChild(@menu.menu)
      @container.appendChild(@stage)

      @_seqMarkerLayer = document.createElement("div")
      @_seqMarkerLayer.className = "biojs_msa_marker"
      @stage.appendChild(@_seqMarkerLayer)

      @stage.style.cursor = "default"

      #END : CONSTRUCTOR

    addDummySequences: ->

      # define seqs
      seqs = [
        new Sequence("MSPFTACAPDRLNAGECTF", "awesome name", 1),
        new Sequence("QQTSPLQQQDILDMTVYCD", "awesome name2", 2),
        new Sequence("FTQHGMSGHEISPPSEPGH", "awesome name3", 3),
      ]
      @addSequences seqs

    _addSequence: (tSeq) ->
      layer = document.createElement("div")
      layer.appendChild @_createLabel(tSeq)  if @visibleElements.labels is true
      layer.appendChild @_createSeqRow(tSeq)  if @visibleElements.sequences is true
      layer.className = "biojs_msa_layer"
      layer.style.height = "#{@columnHeight}px"

      # append to DOM
      @stage.appendChild layer

      # save and add the layer
      @seqs[tSeq.id] = new Row(tSeq, layer)


    #order the stuff ?
    addSequence: (tSeq) ->
      @addSequence tSeq
      @orderSeqsAfterScheme()

    addSequences: (tSeqs) ->
      i = 0

      while i < tSeqs.length
        @_addSequence tSeqs[i]
        i++
      @orderSeqsAfterScheme()


    #
    # creates all amino acids
    #
    _createSeqRow: (tSeq) ->
      residueGroup = document.createDocumentFragment()
      n = 0

      while n < tSeq.seq.length
        residueSpan = document.createElement("span")
        residueSpan.style.width = "#{@columnWidth}px"
        residueSpan.style.height = "#{@columnHeight}px"
        if @columnWidth >= 5
          residueSpan.textContent = tSeq.seq[n]
        else
          residueSpan.textContent = " "

        residueSpan.rowPos = n

        residueSpan.addEventListener "click", ((evt) =>
          id = event.target.parentNode.seqid
          selPos = new selection.PositionSelect(@, id, event.target.rowPos)
          @selmanager.handleSel selPos, evt
        ), false
        if @registerMoveOvers is true
          residueSpan.addEventListener "mouseover", ((evt) =>
            id = event.target.parentNode.seqid
            @selmanager.changeSel new selection.PositionSelect(@, id,
              event.target.rowPos)
          ), false

        # color it nicely
        @colorscheme.colorResidue residueSpan, tSeq, n
        residueGroup.appendChild residueSpan
        n++
      residueSpan = document.createElement("span")
      residueSpan.seqid = tSeq.id
      @colorscheme.colorRow residueSpan, tSeq.id
      residueSpan.appendChild residueGroup
      residueSpan

    _drawSeqMarker: (nMax) ->

      # using fragments is the fastest way
      # try to minimize DOM updates as much as possible
      # http://jsperf.com/innerhtml-vs-createelement-test/6
      residueGroup = document.createDocumentFragment()
      stepSize = 1
      stepSize = 5  if @columnWidth <= 4
      stepSize = 10  if @columnWidth <= 2
      stepSize = 20  if @columnWidth is 1
      n = 0

      while n < nMax
        residueSpan = document.createElement("span")
        residueSpan.textContent = n
        residueSpan.style.width = @columnWidth * stepSize + "px"
        residueSpan.style.display = "inline-block"
        residueSpan.rowPos = n
        residueSpan.stepPos = n / stepSize
        residueSpan.addEventListener "click", ((evt) =>
          @selmanager.handleSel new selection.VerticalSelection(@,
            event.target.rowPos, event.target.stepPos), evt
          return
        ), false
        if @registerMoveOvers is true
          residueSpan.addEventListener "mouseover", ((evt) =>
            @selmanager.changeSel new selection.VerticalSelection(@,
              event.target.rowPos, event.target.stepPos), evt
            return
          ), false

        # color it nicely
        @colorscheme.colorColumn residueSpan, n
        residueGroup.appendChild residueSpan
        n += stepSize

      return residueGroup
    #
    # creates the label of a single seq
    #
    _createLabel: (tSeq) ->
      labelGroup = document.createElement("span")
      labelGroup.textContent = tSeq.name
      labelGroup.seqid = tSeq.id
      labelGroup.className = "biojs_msa_labels"
      labelGroup.style.width = "#{@seqOffset}px"
      labelGroup.style.height = "#{@columnHeight}px"
      labelGroup.style.fontSize = "#{@labelFontsize}px"
      labelGroup.addEventListener "click", ((evt) =>
        id = evt.target.seqid
        @selmanager.handleSel new selection.HorizontalSelection(@, id), evt
        return
      ), false
      if @registerMoveOvers is true
        labelGroup.addEventListener "mouseover", ((evt) =>
          id = evt.target.seqid
          @selmanager.changeSel new selection.HorizontalSelection(@, id)
          return
        ), false
      @colorscheme.colorLabel labelGroup, tSeq
      labelGroup

    orderSeqsAfterScheme: (type) ->
      @ordering.setType type  if type?
      @orderSeqs @ordering.getSeqOrder @seqs


    #
    # redraws the entire MSA
    #
    recolorEntire: ->
      @selmanager.cleanup()

      # all columns
      for curRow of @seqs
        tSeq = @seqs[curRow].tSeq
        currentLayer = @seqs[curRow].layer

        # all residues
        childs = currentLayer.childNodes[1].childNodes
        i = 0

        while i < childs.length
          @colorscheme.colorResidue childs[i], tSeq, childs[i].rowPos
          i++

        #labels
        currentLayerLabel = currentLayer.childNodes[0]
        @colorscheme.colorLabel currentLayerLabel, tSeq

    ###
    # receives an ordered list with seq ids
    ###
    orderSeqs: (orderList) ->
      if orderList.length != Object.size(@seqs)
        @log("Length of the input array "+ orderList.length +
          " does not match with the real world " + Object.size(@seqs))
        return

      spacePerCell = @columnHeight + @columnSpacing
      val = 0

      nMax = 0
      (nMax = Math.max nMax, value.tSeq.seq.length) for key,value of @seqs


      Utils.removeAllChilds @_seqMarkerLayer

      # remove offset
      if not @visibleElements.labels
        @_seqMarkerLayer.style.paddingLeft = "0px"
      else
        @_seqMarkerLayer.style.paddingLeft = "#{@seqOffset}px"

      if @visibleElements.ruler
        val = spacePerCell
        @_seqMarkerLayer.appendChild @_drawSeqMarker nMax

      frag = document.createDocumentFragment()

      frag.appendChild @_seqMarkerLayer

      for i in[0..orderList.length - 1] by 1
        id = orderList[i]
        @seqs[id].layer.style.paddingTop = "#{@columnSpacing}px"
        frag.appendChild @seqs[id].layer

      # add rectangular select box - only once
      if not @rectangular_select?
        ###
        @rectangular_select = new selection.RectangularSelect(@
        frag.appendChild(@rectangular_select.createElement())
        @container.addEventListener('mousemove',@rectangular_select.onMouseMove)
        @container.addEventListener('mousedown',@rectangular_select.onMouseDown)
        @container.addEventListener('mouseup',@rectangular_select.onMouseUp)
        ###
      else
        frag.appendChild @rectangular_select.createElement()

      Utils.removeAllChilds @stage
      @stage.appendChild frag

      # update width
      @stage.width = @seqOffset + nMax * @columnWidth

    # * recolors the rows
    #
    recolorRows: ->

      # all columns
      for curRow of @seqs
        tSeq = @seqs[curRow].tSeq
        currentLayer = @seqs[curRow].layer
        rowGroup = currentLayer.childNodes[1]
        @colorscheme.colorRow rowGroup, rowGroup.seqid
      return

    removeSeq: (id) ->
      seqs[id].layer.destroy()
      delete seqs[id]
      # reorder
      @orderSeqsAfterScheme()

    redrawEntire: ->
      tSeqs = []
      for tSeq of @seqs
        tSeqs.push @seqs[tSeq].tSeq
      @resetStage()
      @addSequences tSeqs


    # TODO: do we create memory leaks here?
    resetStage: ->
      Utils.removeAllChilds @stage

    console: undefined
    setConsole: (name) ->
      @console = document.getElementById(name)


    #
    # * some quick & dirty helper
    #
    log: (msg) ->
      @console.innerHTML = msg  if typeof @console isnt "undefined"

    addZoombar: ->
      zoomForm = document.createElement("form")
      zoomSlider = document.createElement("input")
      zoomSlider.type = "range"
      zoomSlider.name = "points"
      zoomSlider.min = 1
      zoomSlider.max = 15
      zoomForm.appendChild zoomSlider
      @zoomSlider = zoomSlider
      zoomSlider.addEventListener "change", (evt) ->
        console.log @zoomSlider.value
        value = @zoomSlider.value
        @columnWidth = 2 * value
        @labelFontsize = 3 + 2 * value
        @columnHeight = 5 + 3 * value
        @columnSpacing = 0
        @seqOffset = 50 + 20 * value
        @redrawEntire()

      @container.appendChild zoomForm
