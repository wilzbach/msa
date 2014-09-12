SeqView = require("./SeqView")
pluginator = require("../bone/pluginator")
TaylorColors = require "./color/taylor"
ZappoColors = require "./color/zappo"
HydroColors = require "./color/hydrophobicity"
mouse = require "../utils/mouse"
_ = require "underscore"

module.exports = pluginator.extend

  tagName: "canvas"

  initialize: (data) ->
    @g = data.g

    @listenTo @g.zoomer, "change:_alignmentScrollLeft change:_alignmentScrollTop", @render
    @listenTo @g.columns,"change:hidden", @_adjustWidth
    @listenTo @g.zoomer,"change:alignmentWidth", @_adjustWidth

    @ctx = @el.getContext '2d'

    @color = TaylorColors
    @el.setAttribute 'height', @g.zoomer.get "alignmentHeight"
    @el.style.height =  @g.zoomer.get "alignmentHeight"

    #@el.setAttribute 'width', 300
    #@el.style.width = 300

    @manageEvents()

  manageEvents: ->
    events = {}
    if @g.config.get "registerMouseClicks"
      events.click = "_onclick"
    if @g.config.get "registerMouseHover"
      events.mousein = "_onmousein"
      events.mouseout = "_onmouseout"
    @delegateEvents events

    # listen for changes
    @listenTo @g.config, "change:registerMouseHover", @manageEvents
    @listenTo @g.config, "change:registerMouseClick", @manageEvents

  draw: ->
    @removeViews()

    y = - @g.zoomer.get "_alignmentScrollTop"

    rectHeight = @g.zoomer.get "rowHeight"
    @ctx.globalAlpha = 1
    for i in [0.. @model.length - 1] by 1
      continue if @model.at(i).get('hidden')
      @drawSeq {model: @model.at(i), y: y}
      #view = new SeqView {model: @model.at(i), g: @g}
      y = y + rectHeight

      # out of viewport - stop
      if y > @el.height
        break

  drawSeq: (data) ->
    seq = data.model.get "seq"
    y = data.y
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"

    @ctx.font="14px Courier New"
    #@ctx.font="14px Lucida Console"

    x = - @g.zoomer.get "_alignmentScrollLeft"
    # skip unneeded blocks at the beginning
    start = Math.max 0, - Math.ceil(x / rectWidth)
    x = 0

    selection = @_getSelection data.model
    console.log selection

    for j in [start.. seq.length - 1] by 1
      c = seq[j]
      c = c.toUpperCase()
      color = @color[c]
      if color?
        @ctx.fillStyle = "#" + color
        @ctx.fillRect x,y,rectWidth,rectHeight
        @ctx.strokeText c,x + 3,y + 12,rectWidth

      # check for selection
      if selection.indexOf(j) >= 0
        @ctx.lineWidth = 2
        @ctx.fillStyle = "red"
        @ctx.strokeRect x,y,rectWidth,rectHeight
        @ctx.lineWidth = 1

      x = x + rectWidth

      # out of viewport - stop
      if x > @el.width
        break

  _onclick: (e) ->
    coords = mouse.getMouseCoords e
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"
    coords[0] += Math.floor(@g.zoomer.get("_alignmentScrollLeft") / rectWidth) * rectWidth
    coords[1] += Math.floor(@g.zoomer.get("_alignmentScrollTop") / rectHeight) * rectHeight
    x = Math.floor(coords[0] / rectWidth )
    y = Math.floor(coords[1] / rectHeight)
    seqId = @model.at(y).get "id"
    @g.trigger "residue:click", {seqId:seqId, rowPos: x, evt:e}
    console.log x,y
    @render()

  render: ->


    @el.className = "biojs_msa_seq_st_block"
    @el.style.display = "inline-block"
    @el.style.overflowX = "hidden"
    @el.style.overflowY = "hidden"

    @_adjustWidth()
    @draw()

    @

  _getLabelWidth: ->
     paddingLeft = 0
     paddingLeft += @g.zoomer.get "labelWidth" if @g.vis.get "labels"
     paddingLeft += @g.zoomer.get "metaWidth" if @g.vis.get "metacell"
     return paddingLeft

  # TODO: should I be moved to the selection manager?
  # returns an array with the currently selected residues
  # e.g. [0,3] = pos 0 and 3 are selected
  _getSelection: (model) ->
    maxLen = model.get("seq").length
    selection = []
    sels = @g.selcol.getSelForRow model.get "id"
    rows = _.find sels, (el) -> el.get("type") is "row"
    if rows?
      # full match
      for n in [0..maxLen - 1] by 1
        selection.push n
    else if sels.length > 0
      for sel in sels
        for n in [sel.get("xStart")..sel.get("xEnd")] by 1
          selection.push n

    return selection


  _adjustWidth: ->
    if @el.parentNode?
      parentWidth = @el.parentNode.offsetWidth
    else
      parentWidth = document.body.clientWidth

    # TODO: dirty hack
    @maxWidth = parentWidth - @_getLabelWidth() - 35
    @el.style.width = @g.zoomer.get "alignmentWidth"
    calcWidth = @g.zoomer.getAlignmentWidth( @model.getMaxLength() - @g.columns.get('hidden').length)
    if calcWidth > @maxWidth
      @g.zoomer.set "alignmentWidth", @maxWidth
    @el.style.width = Math.min calcWidth, @maxWidth
    @el.setAttribute 'width', @el.style.width
