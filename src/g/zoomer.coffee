Model = require("backbone-thin").Model
# pixel properties for some components
module.exports = Zoomer = Model.extend

  constructor: (attributes,options) ->
    @calcDefaults options.model
    Model.apply @, arguments
    @g = options.g
    @

  defaults:

    # general
    alignmentWidth: "auto"
    alignmentHeight: 195
    columnWidth: 15
    rowHeight: 15
    autoResize: true # only for the width

    # labels
    labelWidth: 100
    metaWidth: 100
    textVisible: true
    labelIdLength: 30
    labelFontsize: 13
    labelLineHeight: "13px"

    # marker
    markerFontsize: "10px"
    stepSize: 1
    markerStepSize: 2

    # canvas
    residueFont: "13" # in px
    canvasEventScale: 1

    # overview box
    boxRectHeight: 2
    boxRectWidth: 2
    overviewboxPaddingTop: 10

    # menu
    menuFontsize: "14px"
    menuItemFontsize: "14px"
    menuItemLineHeight: "14px"
    menuMarginLeft: "3px"
    menuPadding: "3px 4px 3px 4px"

    # internal props
    _alignmentScrollLeft: 0
    _alignmentScrollTop: 0

  # sets some defaults, depending on the model
  calcDefaults: (model) ->
    maxLen = model.getMaxLength()
    if maxLen < 200 and model.length < 30
      @defaults.boxRectWidth = @defaults.boxRectHeight = 5

  # @param n [int] maxLength of all seqs
  getAlignmentWidth: (n) ->
    if @get("alignmentWidth") is "auto" or @get("autoResize")
      @get("columnWidth") * n
    else
      @get "alignmentWidth"

  # @param n [int] number of residues to scroll to the right
  setLeftOffset: (n) ->
    val = (n)
    val = Math.max 0, val
    val -= @g.columns.calcHiddenColumns val
    @set "_alignmentScrollLeft", val * @get('columnWidth')

  # @param n [int] row that should be on top
  setTopOffset: (n) ->
    val = Math.max 0, (n - 1)
    height = 0
    for i in [0..val] by 1
      seq = @model.at i
      height += seq.attributes.height || 1
    @set "_alignmentScrollTop",height * @get("rowHeight")

  # length of all elements left to the main sequence body: labels, metacell, ..
  getLabelWidth: ->
     paddingLeft = 0
     paddingLeft += @get "labelWidth" if @g.vis.get "labels"
     paddingLeft += @get "metaWidth" if @g.vis.get "metacell"
     paddingLeft += 15 # scroll bar
     return paddingLeft

  _adjustWidth: ->
    return unless @el isnt undefined and @model isnt undefined
    if @el.parentNode? and @el.parentNode.offsetWidth isnt 0
      parentWidth = @el.parentNode.offsetWidth
    else
      parentWidth = document.body.clientWidth - 35

    # TODO: dirty hack
    maxWidth = parentWidth - @getLabelWidth()
    calcWidth = @getAlignmentWidth( @model.getMaxLength() - @g.columns.get('hidden').length)
    val = Math.min(maxWidth,calcWidth)
    # round to a valid AA box
    val = Math.floor( val / @get("columnWidth")) * @get("columnWidth")

    @set "alignmentWidth", val

  autoResize:  ->
    if @get "autoResize"
      @_adjustWidth @el, @model

  # max is the maximal allowed height
  autoHeight: (max) ->
    # TODO!
    # make seqlogo height configurable
    val = @getMaxAlignmentHeight()
    if max != undefined and max > 0
      val = Math.min val, max

    @set "alignmentHeight", val

  setEl: (el, model) ->
    @el = el
    @model = model

  # updates both scroll properties (if needed)
  _checkScrolling: (scrollObj, opts) ->
    xScroll = scrollObj[0]
    yScroll = scrollObj[1]

    @set "_alignmentScrollLeft", xScroll, opts
    @set "_alignmentScrollTop", yScroll, opts

  getMaxAlignmentHeight: ->
    height = 0
    @model.each (seq) ->
      height += seq.attributes.height || 1

    return (height * @get("rowHeight"))

  getMaxAlignmentWidth: ->
    return @model.getMaxLength() * @get("columnWidth")

