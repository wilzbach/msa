define ["cs!seq", "./row", "./selection/main" ], (Sequence, Row, selection) ->

  class SeqBuilder

    constructor: (@msa) ->
      undefined

    _addSeqs: (tSeqs) ->
      if true
        @_addSeq e for e in tSeqs
      else
        @_addSeq tSeqs

    _addSeq: (tSeq) ->
      layer = document.createElement "div"
      layer.appendChild @_createLabel tSeq if @msa.config.visibleElements.labels
      layer.appendChild @_createRow tSeq if @msa.config.visibleElements.sequences
      layer.className = "biojs_msa_layer"
      layer.style.height = "#{@msa.zoomer.columnHeight}px"

      # append to DOM
      #msa.stage.appendChild layer

      # save the layer
      @msa.seqs[tSeq.id] = new Row tSeq, layer

    recolorRow: (row) ->
      # all residues
      childs = row.childNodes

      i = 0
      while i < childs.length
        @msa.colorscheme.colorResidue childs[i], tSeq, childs[i].rowPos
        i++

    addDummySequences: ->
      seqs = [
        new Sequence("MSPFTACAPDRLNAGECTF", "awesome name", 1),
        new Sequence("QQTSPLQQQDILDMTVYCD", "awesome name2", 2),
        new Sequence("FTQHGMSGHEISPPSEPGH", "awesome name3", 3),
      ]
      @msa.addSeqs seqs

    _createLabel: (tSeq) ->
      labelGroup = document.createElement("span")
      labelGroup.textContent = tSeq.name
      labelGroup.seqid = tSeq.id
      labelGroup.className = "biojs_msa_labels"
      labelGroup.style.width = "#{@msa.zoomer.seqOffset}px"
      labelGroup.style.height = "#{@msa.zoomer.columnHeight}px"
      labelGroup.style.fontSize = "#{@msa.zoomer.labelFontsize}px"

      labelGroup.addEventListener "click", ((evt) =>
        id = evt.target.seqid
        @msa.selmanager.handleSel new selection.HorizontalSelection(@msa, id), evt
        return
      ), false

      if @msa.config.registerMoveOvers?
        labelGroup.addEventListener "mouseover", ((evt) =>
          id = evt.target.seqid
          @msa.selmanager.changeSel new selection.HorizontalSelection(@msa, id)
          return
        ), false

      @msa.colorscheme.colorLabel labelGroup, tSeq
      labelGroup

    _createRow: (tSeq) ->
      residueGroup = document.createDocumentFragment()
      n = 0

      while n < tSeq.seq.length
        residueSpan = document.createElement("span")
        residueSpan.style.width = "#{@msa.zoomer.columnWidth}px"
        residueSpan.style.height = "#{@msa.zoomer.columnHeight}px"

        # pseudo semantic zooming
        if @msa.zoomer.columnWidth >= 5
          residueSpan.textContent = tSeq.seq[n]
        else
          residueSpan.textContent = " "

        residueSpan.rowPos = n

        residueSpan.addEventListener "click", ((evt) =>
          id = event.target.parentNode.seqid
          selPos = new selection.PositionSelect(@msa, id, event.target.rowPos)
          @msa.selmanager.handleSel selPos, evt
        ), false

        if @registerMoveOvers is true
          residueSpan.addEventListener "mouseover", ((evt) =>
            id = event.target.parentNode.seqid
            @msa.selmanager.changeSel new selection.PositionSelect(@msa, id,
              event.target.rowPos)
          ), false

        # color it nicely
        @msa.colorscheme.colorResidue residueSpan, tSeq, n
        residueGroup.appendChild residueSpan
        n++

      residueSpan = document.createElement("span")
      residueSpan.seqid = tSeq.id
      @msa.colorscheme.colorRow residueSpan, tSeq.id
      residueSpan.appendChild residueGroup
      return residueSpan
