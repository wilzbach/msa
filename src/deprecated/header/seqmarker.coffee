Utils = require "../utils/general"
selection = require "../selection"
headerDiv = require "./headerDiv"

module.exports =
#
# displays the current position of a amino acid
#
class SeqMarker

  constructor: (@msa) ->
    @_seqMarkerLayer = document.createElement "div"
    @_seqMarkerLayer.className = "biojs_msa_marker"

  draw: ->
    unless @msa.config.visibleElements.ruler
      return undefined

    stepSize = @msa.zoomer.getStepSize()

    createElement = (data) =>
      residueSpan = data.target
      n = data.rowPos

      residueSpan.textContent = n
      residueSpan.rowPos = n
      residueSpan.stepPos = n / stepSize

      residueSpan.addEventListener "click", (evt) =>
        @msa.selmanager.handleSel new selection.VerticalSelection(@msa,
          evt.target.rowPos, evt.target.stepPos), evt
      , false

      if @msa.config.registerMoveOvers
        residueSpan.addEventListener "mouseover", ((evt) =>
          @msa.selmanager.changeSel new selection.VerticalSelection(@msa,
            evt.target.rowPos, evt.target.stepPos), evt
        ), false

      # color it nicely
      @msa.colorscheme.trigger "column:color", {target: residueSpan, rowPos: n}

    @_seqMarkerLayer = headerDiv @msa,{element: @_seqMarkerLayer,stepSize:stepSize,
    createElement:createElement}
    return @_seqMarkerLayer
