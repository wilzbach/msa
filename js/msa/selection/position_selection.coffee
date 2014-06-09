define ["cs!msa/selection/selection"], (Selection) ->
  class PositionSelection extends Selection

    constructor: (@msa, @id, @column) ->
      if not @id? or not @column?
        throw new Error "invalid selection coordinates"

    getId: ->
      return "x#{@id}y#{@column}"

    select: =>
      tSeq = @msa.seqs[@id].tSeq

      # color the selected residue
      singleResidue = @msa.seqs[@id].layer.children[1].children[@column]
      @msa.colorscheme.colorSelectedResidueSingle singleResidue,tSeq,@column

    deselect: =>
      posY = @msa.seqs[@id]
      singlePos = posY.layer.childNodes[1].childNodes[@column]
      tSeq = posY.tSeq
      @msa.colorscheme.colorResidue singlePos,tSeq,@column
