define ["./selection.coffee"], (Selection) ->
  class PositionSelection extends Selection

    constructor: (@msa) ->
      @_currentPos = {'x': -1, 'y': -1 }

    select:  (id,rowPos) =>
      @_cleanupSelections()

      tSeq = @msa.seqs[id].tSeq

      # color the selected residue
      singleResidue = @msa.seqs[id].layer.children[1].children[rowPos]
      @msa.colorscheme.colorSelectedResidueSingle singleResidue,tSeq,rowPos

      @_currentPos.y = id
      @_currentPos.x = rowPos

    disselect: () =>
      currentPos = @_currentPos
      if currentPos.x >= 0 && currentPos.y >= 0
        posY = @msa.seqs[currentPos.y]
        singlePos = posY.layer.childNodes[1].childNodes[currentPos.x]
        tSeq = posY.tSeq
        @msa.colorscheme.colorResidue singlePos,tSeq,currentPos.x

      # reset
      _currentPos = {'x': -1, 'y': -1 }



