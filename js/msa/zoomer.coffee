define [], ->
  class Zoomer

    constructor: (@msa) ->

      @maxLabelLength = 20
      @setZoomLevel 2

    setZoomLevel: (value) ->
      @level = value

      @columnWidth = 2 * value
      @labelFontsize = 3 + 2 * value
      @residueFontsize = 3 + 2 * value
      @columnHeight = 5 + 3 * value
      @columnSpacing = 0

      if @maxLabelLength > 0
        @seqOffset = @maxLabelLength * @labelFontsize / 1.8 + 4 * value
      else
        console.log @msa.container.id
        @seqOffset = 50

      if value is 1
        @seqOffset = 5

    autofit: (tSeqs) ->
      level = @guessZoomLevel tSeqs
      @setZoomLevel level

    getStepSize: ->
      stepSize = 1
      stepSize = 5  if @columnWidth <= 4
      stepSize = 10  if @columnWidth <= 2
      stepSize = 20  if @columnWidth is 1
      stepSize

    guessZoomLevel:(tSeqs) ->
      _rect = @msa.container.getBoundingClientRect()
      width = _rect.right - _rect.left
      len = @getMaxLength tSeqs
      @maxLabelLength =  @getMaxLabelLength tSeqs

      level = 2

      if len > width
        # go to minzoom
        return 1
      else
        # increase as long as possible
        @setZoomLevel level
        while @msa.stage.width(len) < width or level is 50
          level++
          @setZoomLevel level
        return level - 1


    getMaxLength: (seqs) ->
      nMax = 0

      if seqs?
        # input array
        for value in seqs
          if value?.seq?
            nMax = Math.max nMax, value.seq.length
      else
        # internal dict
        seqs = @msa.seqs
        for key,value of seqs
          nMax = Math.max nMax, value.tSeq.seq.length
      return nMax

    getMaxLabelLength: (seqs) ->
      nMax = 0

      if seqs?
        # input array
        for value in seqs
          if value?.name?
            nMax = Math.max nMax, value.name.length
      else
        # internal dict
        seqs = @msa.seqs
        for key,value of seqs
          nMax = Math.max nMax, value.tSeq.name.length
      return nMax
