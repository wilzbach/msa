define ["cs!seq", "msa/row", "msa/selection/main",
          "cs!utils/bmath"], (Sequence, Row, selection, BMath) ->

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
    recolorStage: =>
      @msa.selmanager.cleanup()

      # TODO: redundant

      # all columns
      for key,curRow of @msa.seqs
        currentLayer = curRow.layer
        currentLayer.style.height = "#{@msa.zoomer.columnHeight}px"

        # label
        @_setLabelPosition currentLayer.childNodes[0], curRow.tSeq
        @recolorRow currentLayer.childNodes[1], curRow.tSeq

        # row

    # recolor a single row - without the label
    recolorRow: (row, tSeq) ->
      # all residues
      childs = row.childNodes

      @_recolorRow row, tSeq

      i = 0
      while i < childs.length
        @_setResiduePosition childs[i],tSeq
        i++

    removeSeq: (id) ->
      @msa.seqs[id].layer.destroy()
      delete seqs[id]
      # reorder
      @orderSeqsAfterScheme()
      # TODO: maybe redraw ?

    @_generateSequence: (len) ->
      text = ""
      possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

      for i in [0..len - 1] by 1
        text += possible.charAt Math.floor(Math.random() * possible.length)
      return text

    getDummySequences: (len, seqLen) ->
      seqs = []
      len = BMath.getRandomInt 3,5 unless len?
      seqLen = BMath.getRandomInt 50,200 unless seqLen?

      for i in [0..len - 1] by 1
        seqs.push new Sequence(SeqBuilder._generateSequence(seqLen), "seq" + i,
        i)
      return seqs

    addDummySequences: ->
      @msa.addSeqs @getDummySequences()
      @msa._draw()

    _setLabelPosition: (label,tSeq) ->
      label.style.width = "#{@msa.zoomer.seqOffset}px"
      label.style.height = "#{@msa.zoomer.columnHeight}px"
      label.style.fontSize = "#{@msa.zoomer.labelFontsize}px"
      if @msa.zoomer.isTextVisible()
        label.textContent = tSeq.name
      else
        label.textContent = ""

      @msa.colorscheme.colorLabel label,tSeq

    _createLabel: (tSeq) ->
      labelGroup = document.createElement("span")
      labelGroup.seqid = tSeq.id
      labelGroup.className = "biojs_msa_labels"

      @_setLabelPosition labelGroup,tSeq

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

      labelGroup

    _recolorRow: (row,tSeq) ->
      row.style.fontSize = "#{@msa.zoomer.residueFontsize}px"
      @msa.colorscheme.colorRow row, tSeq.id

    _setResiduePosition: (residue,tSeq) ->
      residue.style.width = "#{@msa.zoomer.columnWidth}px"
      residue.style.height = "#{@msa.zoomer.columnHeight}px"

      # pseudo semantic zooming
      if @msa.zoomer.isTextVisible()
        residue.textContent = tSeq.seq[residue.rowPos]
      else
        residue.textContent = " "

      @msa.colorscheme.colorResidue residue,tSeq, residue.rowPos

    _createRow: (tSeq) ->
      residueGroup = document.createDocumentFragment()
      n = 0


      while n < tSeq.seq.length
        residueSpan = document.createElement("span")
        residueSpan.rowPos = n
        @_setResiduePosition residueSpan,tSeq

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

      @_recolorRow residueSpan, tSeq
      residueSpan.appendChild residueGroup

      return residueSpan
