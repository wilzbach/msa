define ["cs!seq", "msa/row", "msa/selection/main" ], (Sequence, Row, selection) ->

  class SeqBuilder

    constructor: (@msa) ->
      undefined

    _addSeqs: (tSeqs) ->
      @msa.zoomer.autofit tSeqs if @msa.config.autofit
      # check whether array or single seq
      unless tSeqs.id?
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

    # recolors all entire stage
    recolorStage: ->
      @selmanager.cleanup()

      # all columns
      for curRow of @seqs
        currentLayer = @seqs[curRow].layer
        @colorscheme.colorLabel LabelBuilder.recolorLabel currentLayer.childNodes[0],@seqs[curRow].tSeq
        seqmgr.recolorRow currentLayer.childNodes[1]

    # recolor a single row - without the label
    recolorRow: (row) ->
      # all residues
      childs = row.childNodes

      i = 0
      while i < childs.length
        @msa.colorscheme.colorResidue childs[i], tSeq, childs[i].rowPos
        i++

    removeSeq: (id) ->
      seqs[id].layer.destroy()
      delete seqs[id]
      # reorder
      @orderSeqsAfterScheme()
      # TODO: maybe redraw ?

    addDummySequences: ->
      seqs = [
        new Sequence("MSPFTACAPDRLNAGECTF", "awesome name", 1),
        new Sequence("QQTSPLQQQDILDMTVYCD", "awesome name2", 2),
        new Sequence("FTQHGMSGHEISPPSEPGH", "awesome name3", 3),
      ]
      @msa.addSeqs seqs

    _createLabel: (tSeq) ->
      labelGroup = document.createElement("span")
      if @msa.zoomer.level >= 2
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

      if @msa.config.registerMoveOvers
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
          id = evt.target.parentNode.seqid
          selPos = new selection.PositionSelect(@msa, id, evt.target.rowPos)
          @msa.selmanager.handleSel selPos, evt
        ), false

        if @registerMoveOvers
          residueSpan.addEventListener "mouseover", ((evt) =>
            id = evt.target.parentNode.seqid
            @msa.selmanager.changeSel new selection.PositionSelect(@msa, id,
              evt.target.rowPos)
          ), false

        # color it nicely
        @msa.colorscheme.colorResidue residueSpan, tSeq, n
        residueGroup.appendChild residueSpan
        n++

      residueSpan = document.createElement("span")
      residueSpan.seqid = tSeq.id
      @msa.colorscheme.colorRow residueSpan, tSeq.id
      residueSpan.appendChild residueGroup
      residueSpan.style.fontSize = "#{@msa.zoomer.residueFontsize}px"
      return residueSpan
