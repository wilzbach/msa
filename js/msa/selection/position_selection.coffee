define ["cs!msa/selection/selection"], (Selection) ->
  class PositionSelection extends Selection

    constructor: (@msa, @_id, @_column) ->
      if not @_id? or not @_column?
        throw new Error "invalid selection coordinates"

    getId: ->
      return "x{@_id}y{@_column}"

    select: =>
      tSeq = @msa.seqs[@_id].tSeq

      # color the selected residue
      singleResidue = @msa.seqs[@_id].layer.children[1].children[@_column]
      @msa.colorscheme.colorSelectedResidueSingle singleResidue,tSeq,@_column

    deselect: =>
      posY = @msa.seqs[@_id]
      singlePos = posY.layer.childNodes[1].childNodes[@_column]
      tSeq = posY.tSeq
      @msa.colorscheme.colorResidue singlePos,tSeq,@_column
