headerDiv = require "./headerDiv"
# displays per column summaries
class ColumnSummary
  constructor: (@msa) ->
    @_seqMarkerLayer = document.createElement "div"
    @_seqMarkerLayer.className = "biojs_msa_column_summary"

  draw: ->

    stepSize = @msa.zoomer.getStepSize()

    createElement = (data) =>
      residueSpan = data.target
      n = data.rowPos

      residueSpan.textContent = "*"
      residueSpan.rowPos = n

    @_seqMarkerLayer = headerDiv @msa,{element: @_seqMarkerLayer,stepSize:stepSize,
    createElement:createElement}
    return @_seqMarkerLayer

module.exports = ColumnSummary
