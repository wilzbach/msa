Model = require("backbone").Model
# pixel properties for some components
module.exports = Zoomer = Model.extend

  defaults:
    columnWidth: 15
    metaWidth: 100
    labelWidth: 100
    alignmentWidth: "auto"
    alignmentHeight: 200

    rowHeight: 15
    textVisible: true
    labelLength: 20
    labelFontsize: "10px"
    stepSize: 1
    markerStepSize: 2

    boxRectHeight: 5
    boxRectWidth: 5

    # internal props
    _alignmentScrollLeft: 0
    _alignmentScrollTop: 0

  # @param n [int] maxLength of all seqs
  getAlignmentWidth: (n) ->
    if @get("alignmentWidth") is "auto"
      @get("columnWidth") * n
    else
      @get "alignmentWidth"

  # @param n [int] number of residues to scroll to the right
  setLeftOffset: (n) ->
    val = (n - 1) * @get('columnWidth')
    val = Math.max 0, val
    @set "_alignmentScrollLeft", val

  # @param n [int] row that should be on top
  setTopOffset: (n) ->
    val = (n - 1) * @get('rowHeight')
    val = Math.max 0, val
    @set "_alignmentScrollTop",val
