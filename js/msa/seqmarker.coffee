define ["./utils", "./selection/main"],(Utils, selection) ->
  class SeqMarker

    constructor: (@msa) ->
      @_seqMarkerLayer = document.createElement "div"
      @_seqMarkerLayer.className = "biojs_msa_marker"

    draw: ->
      Utils.removeAllChilds @_seqMarkerLayer

      unless @msa.config.visibleElements.ruler
        return undefined
      else

        # check for offset
        unless @msa.config.visibleElements.labels
          @_seqMarkerLayer.style.paddingLeft = "0px"
        else
          @_seqMarkerLayer.style.paddingLeft = "#{@msa.zoomer.seqOffset}px"

        spacePerCell = @columnHeight + @columnSpacing
        val = spacePerCell

        # using fragments is the fastest way
        # try to minimize DOM updates as much as possible
        # http://jsperf.com/innerhtml-vs-createelement-test/6
        residueGroup = document.createDocumentFragment()
        stepSize = 1
        stepSize = 5  if @columnWidth <= 4
        stepSize = 10  if @columnWidth <= 2
        stepSize = 20  if @columnWidth is 1
        n = 0

        while n < @msa._nMax
          residueSpan = document.createElement("span")
          residueSpan.textContent = n
          residueSpan.style.width = @msa.zoomer.columnWidth * stepSize + "px"
          residueSpan.style.display = "inline-block"
          residueSpan.rowPos = n
          residueSpan.stepPos = n / stepSize

          residueSpan.addEventListener "click", ((evt) =>
            @msa.selmanager.handleSel new selection.VerticalSelection(@msa,
              event.target.rowPos, event.target.stepPos), evt
          ), false

          if @msa.config.registerMoveOvers?
            residueSpan.addEventListener "mouseover", ((evt) =>
              @msa.selmanager.changeSel new selection.VerticalSelection(@msa,
                event.target.rowPos, event.target.stepPos), evt
            ), false

          # color it nicely
          @msa.colorscheme.colorColumn residueSpan, n
          residueGroup.appendChild residueSpan
          n += stepSize

        @_seqMarkerLayer.appendChild residueGroup
        return @_seqMarkerLayer
