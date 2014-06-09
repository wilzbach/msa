define ["cs!msa/selection/selection"], (Selection) ->
  class VerticalSelection extends Selection

    constructor: (@msa, @_column) ->
      #@_region = new Region

    getId: ->
      @_column

    select: ->
      @_selectLabel @msa.colorscheme.colorSelectedColumn
      @_selectResidues @msa.colorscheme.colorSelectedResidueColumn

    deselect: ->
      @_selectLabel @msa.colorscheme.colorColumn
      @_selectResidues @msa.colorscheme.colorResidue

    _selectLabel: (colorCall) ->
      columnGroup = @msa._seqMarkerLayer.childNodes[@_column]
      colorCall columnGroup, @_column

    _selectResidues: (colorCall) ->
      for key,seq of @msa.seqs
        singlePos = seq.layer.children[1].childNodes[@_column]
        colorCall singlePos,
          seq.tSeq,singlePos.rowPos
