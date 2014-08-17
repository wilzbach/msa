Utils = require "../utils/general"
selection = require "../selection/index"
StageElement = require "./stageElement"
EventHandler = require "biojs-events"

module.exports =
  class SeqElement extends StageElement

    constructor: (@msa) ->
      @msa.on "redraw", @redraw

      # TODO: remove me
      #EventHandler.mixin @.prototype

    # calculates the width of this container
    width: (n) ->
      return n * @msa.zoomer.columnWidth

    # creates an element for every residue
    # and returns the row
    create: (row) ->
      tSeq = row.tSeq
      residueGroup = document.createDocumentFragment()
      spanGlobal = document.createElement("span")
      n = 0

      for n in [0..tSeq.seq.length - 1] by 1
        residueSpan = document.createElement("span")
        residueSpan.rowPos = n
        @setResiduePosition residueSpan,tSeq

        unless @msa.config.speed
          residueSpan.addEventListener "click", ((evt) =>
            seqId = evt.target.parentNode.seqid
            rowPos = evt.target.rowPos
            @msa.trigger "residue:click", {seqId:seqId, rowPos: rowPos, evt:evt,
            target:evt.target}
          ), false

        if @msa.config.registerMoveOvers
          residueSpan.addEventListener "mouseover", ((evt) =>
            seqId = evt.target.parentNode.seqid
            @msa.trigger "residue:mouseover", {seqId:id, rowPos: rowPos, div:
              evt.target}
          ), false
          residueSpan.addEventListener "mouseout", ((evt) =>
            seqId = evt.target.parentNode.seqid
            @msa.trigger "residue:mouseout", {seqId:id, rowPos: rowPos, div:
              evt.target}
          ), false

        # color it nicely
        #unless @msa.config.speed
        @msa.colorscheme.trigger "residue:color", {target: residueSpan, seqId: tSeq.id,
        rowPos: n}
        spanGlobal.appendChild residueSpan

      spanGlobal.seqid = tSeq.id

      @redrawDiv spanGlobal, tSeq

      return spanGlobal

    # TODO: refactor
    redraw: (el,row,textVisibilityChanged) ->
      tSeq = row.tSeq
      @redrawDiv el, tSeq

      if textVisibilityChanged
        childs = el.childNodes
        for i in [0..childs.length - 1] by 1
          @setResiduePosition childs[i],tSeq

    redrawDiv: (row,tSeq) ->
      row.style.fontSize = "#{@msa.zoomer.residueFontsize}px"
      @msa.colorscheme.trigger "row:color", {rowPos:row, seqId: tSeq.id, target: row}
      row.className += " biojs-msa-stage-level" + @msa.zoomer.level

    setResiduePosition: (residue,tSeq) ->

      # pseudo semantic zooming
      if @msa.zoomer.isTextVisible()
        residue.textContent = tSeq.seq[residue.rowPos]
      else
        residue.textContent = ""

      #@msa.colorscheme.colorResidue residue,tSeq, residue.rowPos
