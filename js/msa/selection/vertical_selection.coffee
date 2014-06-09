define ["cs!msa/selection/selection"], (Selection) ->
  class VerticalSelection extends Selection

    constructor: (@msa, @_column, @_labelColumn) ->
      if not @_labelColumn?
        @_labelColumn = @_column

    getId: ->
      "v" + @_column

    select: ->
      @_selectLabel @msa.colorscheme.colorSelectedColumn
      @_selectResidues @msa.colorscheme.colorSelectedResidueColumn

    deselect: ->
      @_selectLabel @msa.colorscheme.colorColumn
      @_selectResidues @msa.colorscheme.colorResidue

    _selectLabel: (colorCall) ->
      columnGroup = @msa._seqMarkerLayer.childNodes[@_labelColumn]
      colorCall columnGroup, @_labelColumn

    _selectResidues: (colorCall) ->
      for key,seq of @msa.seqs
        singlePos = seq.layer.children[1].childNodes[@_column]
        colorCall singlePos,
          seq.tSeq,singlePos.rowPos
