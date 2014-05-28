define ["./selection.coffee"], (Selection) ->
  class HorizontalSection extends Selection

    constructor: (@msa) ->
      @_currentRow = -1

    # Selects a row (does not send any event)
    select: (id) =>
      @_cleanupSelections()

      currentLayer = @msa.seqs[id].layer
      tSeq = @msa.seqs[id].tSeq

      # color selected row
      childs = currentLayer.childNodes[1].childNodes
      for child, i in childs
        @msa.colorscheme.colorSelectedResidue child,tSeq,i

      # label
      currentLayerLabel = currentLayer.children[0]
      @msa.labelColorScheme.colorSelectedLabel currentLayerLabel, tSeq

      @_currentRow = id

    disselect: () ->
      currentRow = @_currentRow
      if currentRow >= 0
        tSeq = @msa.seqs[currentRow].tSeq
        currentLayer = @msa.seqs[currentRow].layer

        # all residues
        childs = currentLayer.childNodes[1].childNodes
        for child,i in childs
          @msa.colorscheme.colorResidue child,tSeq,i

        # label
        currentLayerLabel = currentLayer.childNodes[0]
        @msa.labelColorScheme.colorLabel currentLayerLabel,tSeq

      # save reset
      _currentRow = -1


