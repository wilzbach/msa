define ["msa/utils", "msa/row"], (Utils, Row) ->
  class Stage

    constructor: (@msa) ->
      # unique stage id
      @ID =  String.fromCharCode(65 + Math.floor(Math.random() * 26))
      @globalID = 'biojs_msa_' + @ID

    _createContainer: ->
      # TODO: remove old canvas
      @canvas = document.createElement "div"
      @canvas.setAttribute "id","#{@globalID}_canvas"
      @canvas.setAttribute "class", "biojs_msa_stage"

    width: (n) ->
      return @msa.zoomer.seqOffset + n * @msa.zoomer.columnWidth

    reset: ->
      Utils.removeAllChilds @canvas

    addSeqs: (tSeqs) ->
      @msa.zoomer.autofit tSeqs if @msa.config.autofit
      # check whether array or single seq
      unless tSeqs.id?
        @addSeq e for e in tSeqs
      else
        @addSeq tSeqs

    addSeq: (tSeq) ->
      @msa.seqs[tSeq.id] = new Row tSeq, undefined

    removeSeq: (id) ->
      @msa.seqs[id].layer.destroy()
      delete seqs[id]
      # reorder
      @orderSeqsAfterScheme()
      # TODO: maybe redraw ?


    drawSeqs: ->
      for key,value of @msa.seqs
        @drawSeq value

    drawSeq: (row) ->
      layer = document.createElement "div"
      layer.appendChild @_createLabel row.tSeq if @msa.config.visibleElements.labels
      layer.appendChild @_createRow row.tSeq if @msa.config.visibleElements.sequences
      layer.className = "biojs_msa_layer"
      layer.style.height = "#{@msa.zoomer.columnHeight}px"

      row.layer = layer

    draw: ->

      # reset stage
      #Utils.removeAllChilds @canvas
      if @canvas?
        @recolorStage()
        console.log "recoloring"
      else
        @_createContainer()
        @drawSeqs()

        orderList = @msa.ordering.getSeqOrder @msa.seqs

        unless orderList?
          console.log "empty seq stage"
          return

        # consistency check
        if orderList.length != Object.size @msa.seqs
          console.log "Length of the input array "+ orderList.length +
            " does not match with the real world " + Object.size @msa.seqs
          return

        # prepare stage
        frag = document.createDocumentFragment()
        for i in[0..orderList.length - 1] by 1
          id = orderList[i]
          @msa.seqs[id].layer.style.paddingTop = "#{@msa.zoomer.columnSpacing}px"
          frag.appendChild @msa.seqs[id].layer

        @canvas.appendChild frag
      return @canvas

    # recolors all entire stage
    recolorStage: =>
      @msa.selmanager.cleanup()

      textVisibilityChanged = false
      if @internalTextDisplay isnt @msa.zoomer.isTextVisible()
        textVisibilityChanged = true
        @internalTextDisplay = @msa.zoomer.isTextVisible()

      # all columns
      for key,curRow of @msa.seqs
        currentLayer = curRow.layer
        # TODO: redundant
        currentLayer.style.height = "#{@msa.zoomer.columnHeight}px"

        # label
        @_setLabelPosition currentLayer.childNodes[0], curRow.tSeq

        # row
        @recolorRow currentLayer.childNodes[1],
        curRow.tSeq,textVisibilityChanged

    # recolor a single row - without the label
    recolorRow: (row, tSeq, textVisibilityChanged) ->
      @_recolorRow row, tSeq

      if textVisibilityChanged
        childs = row.childNodes
        for i in [0..childs.length] by 1
          unless childs[i]?
            console.log i + " " + tSeq.seq
          else
            @_setResiduePosition childs[i],tSeq


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
      row.className += " biojs-msa-stage-level" + @msa.zoomer.level

    _setResiduePosition: (residue,tSeq) ->

      # pseudo semantic zooming
      if @msa.zoomer.isTextVisible()
        residue.textContent = tSeq.seq[residue.rowPos]
      else
        residue.textContent = " "

      #@msa.colorscheme.colorResidue residue,tSeq, residue.rowPos

    _createRow: (tSeq) ->
      residueGroup = document.createDocumentFragment()
      n = 0


      for n in [0..tSeq.seq.length - 1] by 1
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

      residueSpan = document.createElement("span")
      residueSpan.seqid = tSeq.id

      @_recolorRow residueSpan, tSeq
      residueSpan.appendChild residueGroup

      return residueSpan
