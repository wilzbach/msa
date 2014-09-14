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
    alignmentHeight: 200

    rowHeight: 16
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
      parentWidth = document.body.clientWidth

    # TODO: dirty hack
    maxWidth = parentWidth - @getLabelWidth() - 35
    calcWidth = @g.zoomer.getAlignmentWidth( model.getMaxLength() - @g.columns.get('hidden').length)
    if calcWidth > maxWidth
      @set "alignmentWidth", maxWidth
    #el.style.width = Math.min calcWidth, maxWidth

  # updates both scroll properties (if needed)
  _checkScrolling: (scrollObj, opts) ->
    xScroll = scrollObj[0]
    yScroll = scrollObj[1]

    @set "_alignmentScrollLeft", xScroll, opts
    @set "_alignmentScrollTop", yScroll, opts
