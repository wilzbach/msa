define ["cs!msa/selection/selection"], (Selection) ->
  class HorizontalSelection extends Selection

    constructor: (@msa, @id) ->
      undefined

    getId: ->
      "h" + @id

    # Selects a row (does not send any event)
    select: =>
      @_selectLabel @msa.colorscheme.colorSelectedLabel
      @_selectResidues @msa.colorscheme.colorSelectedResidue

    deselect: =>
      @_selectLabel @msa.colorscheme.colorLabel
      @_selectResidues @msa.colorscheme.colorResidue

    _selectLabel: (colorCall) ->
      tSeq = @msa.seqs[@id].tSeq
      currentLayerLabel = @msa.seqs[@id].layer.childNodes[0]
      colorCall currentLayerLabel,tSeq

    _selectResidues: (colorCall) ->
      currentLayer = @msa.seqs[@id].layer
      tSeq = @msa.seqs[@id].tSeq

      childs = currentLayer.childNodes[1].childNodes
      for child, i in childs
        colorCall child,tSeq,i
