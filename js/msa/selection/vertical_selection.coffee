define ["./highlightor.coffee"], (Selection) ->
  class VerticalSelection extends Selection

    constructor: () ->
      @_currentColumn = -1

    select: (selColumn) =>
      @_cleanupSelections()

      if selColumn >= 0
        columnGroup = @msa._seqMarkerLayer.childNodes[selColumn]
        @msa.colorscheme.colorSelectedColumn columnGroup, selColumn
        for key,seq of @msa.seqs
          singlePos = seq.layer.children[1].childNodes[selColumn]
          @msa.colorscheme.colorSelectedResidueColumn singlePos,
            seq.tSeq,singlePos.rowPos

      @_currentColumn = selColumn

    disselect: () ->
      currentColumn = @_currentColumn
      if currentColumn >= 0
        columnGroup = @msa._seqMarkerLayer.childNodes[currentColumn]
        @msa.colorscheme.colorColumn columnGroup, currentColumn
        for key,seq of @msa.seqs
          singlePos = seq.layer.childNodes[1].childNodes[currentColumn]
          @msa.colorscheme.colorResidue singlePos,seq.tSeq,singlePos.rowPos

      # save the reset
      _currentColumn = -1
