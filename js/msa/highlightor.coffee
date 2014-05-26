define [], () ->
  class Highlightor

    _currentRow : -1
    _currentColumn : -1
    _currentPos : {'x': -1, 'y': -1 }

    constructor: (@msa) ->

    # Selects a row (does not send any event)
    selectSeq: (id) =>
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

    _removeHorizontalSelection: () ->
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
    _currentRow : -1

    selectResidue:  (id,rowPos) =>
      @_cleanupSelections()

      tSeq = @msa.seqs[id].tSeq

      # color the selected residue
      singleResidue = @msa.seqs[id].layer.children[1].children[rowPos]
      @msa.colorscheme.colorSelectedResidueSingle singleResidue,tSeq,rowPos

      @_currentPos.y = id
      @_currentPos.x = rowPos

    _removePositionSelection: () =>
      currentPos = @_currentPos
      if currentPos.x >= 0 && currentPos.y >= 0
        singlePos =@msa.seqs[currentPos.y].layer.childNodes[1].childNodes[currentPos.x]
        tSeq = @msa.seqs[currentPos.y].tSeq
        @msa.colorscheme.colorResidue singlePos,tSeq,currentPos.x

      # reset
      _currentPos : {'x': -1, 'y': -1 }

    selectColumn: (selColumn) =>
      @_cleanupSelections()

      if selColumn >= 0
        columnGroup = @msa._seqMarkerLayer.childNodes[selColumn]
        @msa.colorscheme.colorSelectedColumn columnGroup, selColumn
        for key,seq of @msa.seqs
          singlePos = seq.layer.children[1].childNodes[selColumn]
          @msa.colorscheme.colorSelectedResidueColumn(singlePos,seq.tSeq,singlePos.rowPos)

      @_currentColumn = selColumn

    _removeVerticalSelection: () ->
      currentColumn = @_currentColumn
      if currentColumn >= 0
        columnGroup = @msa._seqMarkerLayer.childNodes[currentColumn]
        @msa.colorscheme.colorColumn columnGroup, currentColumn
        for key,seq of @msa.seqs
          singlePos = seq.layer.childNodes[1].childNodes[currentColumn]
          @msa.colorscheme.colorResidue singlePos,seq.tSeq,singlePos.rowPos

      # save the reset
      _currentColumn : -1

     # removes all existing selections
    _cleanupSelections: () ->
      @_removeHorizontalSelection()
      @_removeVerticalSelection()
      @_removePositionSelection()
