SeqView = require("./SeqView")
pluginator = require("../bone/pluginator")
mouse = require "../utils/mouse"
colorSelector = require("biojs-vis-colorschemes").selector
_ = require "underscore"
FontCache = require "./CanvasFontCache"

module.exports = pluginator.extend

  tagName: "canvas"

  initialize: (data) ->
    @g = data.g

    @listenTo @g.zoomer, "change:_alignmentScrollLeft change:_alignmentScrollTop", @render
    @listenTo @g.columns,"change:hidden", @_adjustWidth
    @listenTo @g.zoomer,"change:alignmentWidth", @_adjustWidth
    @listenTo @g.colorscheme, "change:scheme", @render
    @listenTo @g.selcol, "reset add", @render

    @ctx = @el.getContext '2d'

    @el.setAttribute 'height', @g.zoomer.get "alignmentHeight"
    @el.style.height =  @g.zoomer.get "alignmentHeight"

    #@el.setAttribute 'width', 300
    #@el.style.width = 300

    @cache = new FontCache()

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

    rectHeight = @g.zoomer.get "rowHeight"
    start = Math.max 0, Math.abs(Math.ceil( - @g.zoomer.get('_alignmentScrollTop') / rectHeight))
    y = - Math.abs( - @g.zoomer.get('_alignmentScrollTop') % rectHeight)

    console.log start,y

    rectHeight = @g.zoomer.get "rowHeight"
    @ctx.globalAlpha = 1
    for i in [start.. @model.length - 1] by 1
      continue if @model.at(i).get('hidden')
      @drawSeq {model: @model.at(i), y: y}
      y = y + rectHeight
      # out of viewport - stop
      if y > @el.height
        break

    y = - Math.abs( - @g.zoomer.get('_alignmentScrollTop') % rectHeight)
    # draw again - overlays
    for i in [start.. @model.length - 1] by 1
      continue if @model.at(i).get('hidden')
      @drawSeqExtended {model: @model.at(i), y: y}
      y = y + rectHeight
      # out of viewport - stop
      if y > @el.height
        break

  drawSeq: (data) ->
    seq = data.model.get "seq"
    y = data.y
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"


    # skip unneeded blocks at the beginning
    start = Math.max 0, Math.abs(Math.ceil( - @g.zoomer.get('_alignmentScrollLeft') / rectWidth))
    x = - Math.abs( - @g.zoomer.get('_alignmentScrollLeft') % rectWidth)

    for j in [start.. seq.length - 1] by 1
      c = seq[j]
      c = c.toUpperCase()
      color = @color[c]
      if color?
        @ctx.fillStyle = color
        @ctx.fillRect x,y,rectWidth,rectHeight
        #@ctx.strokeText c,x + 3,y + 12,rectWidth
        @ctx.drawImage @cache.getFontTile(letter:c, width:rectWidth, height:
          rectHeight), x, y,rectWidth,rectHeight

      x = x + rectWidth
      # out of viewport - stop
      if x > @el.width
        break

  drawSeqExtended: (data) ->
    seq = data.model.get "seq"
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"

    start = Math.max 0, Math.abs(Math.ceil( - @g.zoomer.get('_alignmentScrollLeft') / rectWidth))
    x = - Math.abs( - @g.zoomer.get('_alignmentScrollLeft') % rectWidth)
    xZero = x - start * rectWidth

    selection = @_getSelection data.model
    [mPrevSel,mNextSel] = @_getPrevNextSelection data.model
    features = data.model.get "features"

    yZero = Math.ceil(data.y / rectHeight) * rectHeight

    for j in [start.. seq.length - 1] by 1
      starts = features.startOn j
      if starts.length > 0
        for f in starts
          @appendFeature f: f,xZero: x, yZero: yZero

      x = x + rectWidth
      # out of viewport - stop
      if x > @el.width
        break

    @_appendSelection model: data.model, xZero: xZero, yZero: yZero

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
    @render()

  render: ->

    @el.className = "biojs_msa_seq_st_block"
    @el.style.display = "inline-block"
    @el.style.overflowX = "hidden"
    @el.style.overflowY = "hidden"

    @color = colorSelector.getColor @g

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

  appendFeature: (data) ->
    f = data.f
    # TODO: this is a very naive way of using SVG to display features
    boxWidth = @g.zoomer.get("columnWidth")
    boxHeight = @g.zoomer.get("rowHeight")
    width = (f.get("xEnd") - f.get("xStart")) * boxWidth

    beforeWidth = @ctx.lineWidth
    @ctx.lineWidth = 3
    beforeStyle = @ctx.strokeStyle
    @ctx.strokeStyle = f.get "fillColor"


    @ctx.strokeRect data.xZero, data.yZero, width,boxHeight
    @ctx.strokeStyle = beforeStyle
    @ctx.lineWidth = beforeWidth

  # displays the current user selection
  # and checks the prev and next row for selection  -> no borders in a selection
  _renderSelection: (data) ->

    xZero = data.xZero
    yZero = data.yZero
    n = data.n
    selection = data.selection
    mPrevSel= data.mPrevSel
    mNextSel = data.mNextSel

    # get the length of this selection
    selectionLength = 0
    for i in [n.. data.model.get("seq").length - 1] by 1

      if selection.indexOf(i) >= 0
        selectionLength++
      else
        break

    # TODO: ugly!
    boxWidth = @g.zoomer.get("columnWidth")
    boxHeight = @g.zoomer.get("rowHeight")
    totalWidth = (boxWidth * selectionLength) + 1

    hidden = @g.columns.get('hidden')

    @ctx.beginPath()
    beforeWidth = @ctx.lineWidth
    @ctx.lineWidth = 3
    beforeStyle = @ctx.strokeStyle
    @ctx.strokeStyle = "#FF0000"

    xZero += n * boxWidth

    # split up the selection into single cells
    xPart = 0
    for i in [0.. selectionLength - 1]
      xPos = n + i
      if hidden.indexOf(xPos) >= 0
        continue
      # upper line
      unless mPrevSel? and mPrevSel.indexOf(xPos) >= 0
        @ctx.moveTo xZero + xPart, yZero
        @ctx.lineTo xPart + boxWidth + xZero, yZero
      # lower line
      unless mNextSel? and mNextSel.indexOf(xPos) >= 0
        @ctx.moveTo xPart + xZero, boxHeight + yZero
        @ctx.lineTo xPart + boxWidth + xZero, boxHeight + yZero

      xPart += boxWidth

    # left
    @ctx.moveTo xZero,yZero
    @ctx.lineTo xZero, boxHeight + yZero

    # right
    @ctx.moveTo xZero + totalWidth,yZero
    @ctx.lineTo xZero + totalWidth, boxHeight + yZero

    @ctx.stroke()
    @ctx.strokeStyle = beforeStyle
    @ctx.lineWidth = beforeWidth

  _appendSelection: (data) ->
    seq = data.model.get("seq")
    selection = @_getSelection data.model
    hidden = @g.columns.get "hidden"
    # get the status of the upper and lower row
    [mPrevSel,mNextSel] = @_getPrevNextSelection data.model

    boxWidth = @g.zoomer.get("columnWidth")
    boxHeight = @g.zoomer.get("rowHeight")

    # avoid unnecessary loops
    return if selection.length is 0

    hiddenOffset = 0
    for n in [0..seq.length - 1] by 1
      if hidden.indexOf(n) >= 0
        hiddenOffset++
      else
        k = n - hiddenOffset
        # only if its a new selection
        if selection.indexOf(n) >= 0 and (k is 0 or selection.indexOf(n - 1) < 0 )
          @_renderSelection n:n,selection: selection,mPrevSel: mPrevSel,mNextSel:mNextSel, xZero: data.xZero, yZero: data.yZero, model: data.model



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

  _getPrevNextSelection: (model) ->
    # looks at the selection of the prev and next el
    # TODO: this is very naive, as there might be gaps above or below

    modelPrev = model.collection.prev model
    modelNext = model.collection.next model
    mPrevSel = @_getSelection modelPrev if modelPrev?
    mNextSel = @_getSelection modelNext if modelNext?
    [mPrevSel,mNextSel]


