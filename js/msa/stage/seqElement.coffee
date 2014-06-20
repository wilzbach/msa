define ["cs!msa/stage/StageElement","msa/selection/main"], (StageElement,
        selection) ->

  class SeqElement extends StageElement

    constructor: (@msa) ->
      undefined

    width: (n) ->
      return n * @msa.zoomer.columnWidth

    setResiduePosition: (residue,tSeq) ->

      # pseudo semantic zooming
      if @msa.zoomer.isTextVisible()
        residue.textContent = tSeq.seq[residue.rowPos]
      else
        residue.textContent = " "

      #@msa.colorscheme.colorResidue residue,tSeq, residue.rowPos

    redraw: (el,tSeq,textVisibilityChanged) ->
      @redrawDiv el, tSeq

      if textVisibilityChanged
        childs = el.childNodes
        for i in [0..childs.length - 1] by 1
          @setResiduePosition childs[i],tSeq

    redrawDiv: (row,tSeq) ->
      row.style.fontSize = "#{@msa.zoomer.residueFontsize}px"
      @msa.colorscheme.colorRow row, tSeq.id
      row.className += " biojs-msa-stage-level" + @msa.zoomer.level

    create: (tSeq) ->
      residueGroup = document.createDocumentFragment()
      n = 0


      for n in [0..tSeq.seq.length - 1] by 1
        residueSpan = document.createElement("span")
        residueSpan.rowPos = n
        @setResiduePosition residueSpan,tSeq

        residueSpan.addEventListener "click", ((evt) =>
          id = evt.target.parentNode.seqid
          selPos = new selection.PositionSelect(@msa, id, evt.target.rowPos)
          @msa.selmanager.handleSel selPos, evt
        ), false

        if @msa.config.registerMoveOvers
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

      @redrawDiv residueSpan, tSeq
      residueSpan.appendChild residueGroup

      return residueSpan
