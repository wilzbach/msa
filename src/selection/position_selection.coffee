Selection = require "./selection"

module.exports =
  class PositionSelection extends Selection

    constructor: (@msa, @id, @column) ->
      if not @id? or not @column?
        throw new Error "invalid selection coordinates"

    getId: ->
      return "x#{@id}y#{@column}"

    select: =>
      tSeq = @msa.seqs[@id].tSeq

      # color the selected residue
      if @msa.seqs[@id].layer.children[1]?
        singleResidue = @msa.seqs[@id].layer.children[1].children[@column]
      else
        singleResidue = @msa.seqs[@id].layer.children[0].children[@column]
        
      @msa.colorscheme.trigger "residue:select", {target:singleResidue,seqId:@id,rowPos:@column}

    deselect: =>
      posY = @msa.seqs[@id]
      if posY.layer.childNodes[2]?
        singleResidue = posY.layer.childNodes[2].childNodes[@column]
      else
        singleResidue = posY.layer.childNodes[0].childNodes[@column]
      tSeq = posY.tSeq
      @msa.colorscheme.trigger "residue:color", {target:singleResidue,seqId:@id,rowPos:@column}
