define [], ->
  class Zoomer

    constructor: (@msa) ->

      @maxLabelLength = 20
      @setZoomLevel 2
      @len = 0

    setZoomLevel: (value) ->
      @level = value

      @columnWidth = 1 * value
      @labelFontsize = 3 + 1 * value
      @residueFontsize = 3 + 1 * value
      @columnHeight = 5 + 1 * value
      @columnSpacing = 0

      if @maxLabelLength > 0
        @seqOffset = @maxLabelLength * @labelFontsize / 2 + 1 * value

      if value is 1
        @seqOffset = 20

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
      @len = @getMaxLength tSeqs
      @maxLabelLength =  @getMaxLabelLength tSeqs

      level = 2

      if @len > width
        # go to minzoom
        return 1
      else
        # increase as long as possible
        @setZoomLevel level
        while @msa.stage.width(@len) < width or level is 200
          level++
          @setZoomLevel level

        if level is 2
          console.log "len: #{@len} - width: #{width}"
          console.log "stage: #{@msa.stage.width(@len)}"
          console.log "stage: #{@msa.container.id}"
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
