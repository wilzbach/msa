Model = require("backbone").Model
# pixel properties for some components
module.exports = Zoomer = Model.extend

  constructor: (attributes,options) ->
    Model.apply @, arguments
    @g = options.g
    @

  defaults:
    columnWidth: 15
    metaWidth: 100
    labelWidth: 100
    alignmentWidth: "auto"
    alignmentHeight: 195

    rowHeight: 15
    textVisible: true
    labelIdLength: 30
    labelFontsize: "13px"
    stepSize: 1
    markerStepSize: 2

    residueFont: "13px mono"
    canvasEventScale: 1

    boxRectHeight: 5 # overview box
    boxRectWidth: 5 # overview box
    overviewAverageSeqs: 1

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

  # length of all elements left to the main sequence body: labels, metacell, ..
  getLabelWidth: ->
     paddingLeft = 0
     paddingLeft += @get "labelWidth" if @g.vis.get "labels"
     paddingLeft += @get "metaWidth" if @g.vis.get "metacell"
     return paddingLeft

  _adjustWidth: (el, model) ->
    if el.parentNode?
      parentWidth = el.parentNode.offsetWidth
    else
      parentWidth = document.body.clientWidth - 35

    # TODO: dirty hack
    maxWidth = parentWidth - @getLabelWidth()
    calcWidth = @getAlignmentWidth( model.getMaxLength() - @g.columns.get('hidden').length)
    val = Math.min(maxWidth,calcWidth)
    # round to a valid AA box
    val = Math.floor( val / @get("columnWidth")) * @get("columnWidth")
    @set "alignmentWidth", val
    #el.style.width = Math.min calcWidth, maxWidth

  # updates both scroll properties (if needed)
  _checkScrolling: (scrollObj, opts) ->
    xScroll = scrollObj[0]
    yScroll = scrollObj[1]

    @set "_alignmentScrollLeft", xScroll, opts
    @set "_alignmentScrollTop", yScroll, opts
