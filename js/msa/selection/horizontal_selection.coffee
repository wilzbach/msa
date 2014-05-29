define ["cs!./selection"], (Selection) ->
  class HorizontalSelection extends Selection

    constructor: (@msa, @_id) ->
      undefined

    getId: ->
      @_id

    # Selects a row (does not send any event)
    select: ->
      @_selectLabel @msa.labelColorScheme.colorSelectedLabel
      @_selectResidues @msa.colorscheme.colorSelectedResidue

    deselect: ->
      @_selectLabel @msa.labelColorScheme.colorLabel
      @_selectResidues @msa.colorscheme.colorResidue

    _selectLabel: (colorCall) ->
      tSeq = @msa.seqs[@_id].tSeq
      currentLayerLabel = @msa.seqs[@_id].layer.childNodes[0]
      colorCall currentLayerLabel,tSeq

    _selectResidues: (colorCall) ->
      currentLayer = @msa.seqs[@_id].layer
      tSeq = @msa.seqs[@_id].tSeq

      childs = currentLayer.childNodes[1].childNodes
      for child, i in childs
        colorCall child,tSeq,i
