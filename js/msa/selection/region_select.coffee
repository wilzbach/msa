define [], ->
  class RegionSelect

    constructor: (@msa, @_y, @_column, @_width, @_height) ->
      undefined

    getId: ->
      return "x{@_id}y{@_column}w{@_width}h{@_height}"

    select: =>
      @_selectResidues @msa.colorscheme.colorSelectedResidueSingle

    deselect: =>
      @_selectResidues @msa.colorscheme.colorResidue

    _selectResidues: (colorCall) ->
      # loop over sequences
      for row in [x .. x + @_height]
        # loop over residues
        curSeq = @msa.seqs[@_id]
        for col in [@_column .. @_column + @_width]

          singleResidue = curSeq.layer.children[1].children[@_column]
          colorCall singleResidue,curSeq.tSeq,col
