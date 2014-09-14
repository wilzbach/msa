pluginator = require("../bone/pluginator")
mouse = require "../utils/mouse"
colorSelector = require("biojs-vis-colorschemes").selector
_ = require "underscore"
jbone = require "jbone"
FontCache = require "./CanvasFontCache"

module.exports = pluginator.extend

  tagName: "canvas"

  initialize: (data) ->
    @g = data.g

    @listenTo @g.zoomer, "change:_alignmentScrollLeft change:_alignmentScrollTop", (model,value, options) ->
      if (not options?.origin?) or options.origin isnt "canvasseq"
        @render()

    @listenTo @g.columns,"change:hidden", @render
    @listenTo @g.zoomer,"change:alignmentWidth", @render
    @listenTo @g.colorscheme, "change", @render
    @listenTo @g.selcol, "reset add", @render

    # el props
    @el.style.display = "inline-block"
    @el.style.overflowX = "hidden"
    @el.style.overflowY = "hidden"
    @el.className = "biojs_msa_seq_st_block"

    @ctx = @el.getContext '2d'
    @cache = new FontCache @g

    # throttle the expensive draw function
    @throttleTime = 0
    @throttleCounts = 0
    if document.documentElement.style.webkitAppearance?
      # webkit browser - no throttling needed
      @throttledDraw = ->
        start = +new Date()
        @draw()
        @throttleTime += +new Date() - start
        @throttleCounts++
        if @throttleCounts > 15
          tTime = Math.ceil(@throttleTime / @throttleCounts)
          console.log "avgDrawTime/WebKit", tTime
          # remove perf analyser
          @throttledDraw = @draw
    else
      # slow browsers like Gecko
      @throttledDraw = _.throttle @throttledDraw, 30

    @manageEvents()

  # measures the time of a redraw and thus set the throttle limit
  throttledDraw: ->
    # +new is the fastest: http://jsperf.com/new-date-vs-date-now-vs-performance-now/6
    start = +new Date()
    @draw()
    @throttleTime += +new Date() - start
    @throttleCounts++

    # remove itself after analysis
    if @throttleCounts > 15
      tTime = Math.ceil(@throttleTime / @throttleCounts)
      console.log "avgDrawTime", tTime
      tTime *=  1.2 # add safety time
      tTime = Math.max 20, tTime # limit for ultra fast computers
      @throttledDraw = _.throttle @draw, tTime

  manageEvents: ->
    events = {}
    events.mousedown = "_onmousedown"
    events.touchstart = "_ontouchstart"

    if @g.config.get "registerMouseClicks"
      events.click = "_onclick"
    if @g.config.get "registerMouseHover"
      events.mousein = "_onmousein"
      events.mouseout = "_onmouseout"

    events.mousewheel = "_onmousewheel"
    events.DOMMouseScroll = "_onmousewheel"
    @delegateEvents events

    # listen for changes
    @listenTo @g.config, "change:registerMouseHover", @manageEvents
    @listenTo @g.config, "change:registerMouseClick", @manageEvents
    @dragStart = []

  draw: ->

    # fastest way to clear the canvas
    # http://jsperf.com/canvas-clear-speed/25
    @el.width = @el.width

    rectHeight = @g.zoomer.get "rowHeight"

    # rects
    @ctx.globalAlpha = @g.colorscheme.get "opacity"
    @drawSeqs (data) -> @drawSeq(data, @_drawRect)
    @ctx.globalAlpha = 1

    # letters
    @drawSeqs (data) -> @drawSeq(data, @_drawLetter)

    # features, selection
    @drawSeqs @drawSeqExtended

  drawSeqs: (callback) ->
    rectHeight = @g.zoomer.get "rowHeight"
    start = Math.max 0, Math.abs(Math.ceil( - @g.zoomer.get('_alignmentScrollTop') / rectHeight))
    y = - Math.abs( - @g.zoomer.get('_alignmentScrollTop') % rectHeight)
    for i in [start.. @model.length - 1] by 1
      continue if @model.at(i).get('hidden')
      callback.call @, {model: @model.at(i), y: y}
      y = y + rectHeight
      # out of viewport - stop
      if y > @el.height
        break

  # TODO: very expensive method
  drawSeq: (data, callback) ->
    seq = data.model.get "seq"
    y = data.y
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"

    # skip unneeded blocks at the beginning
    start = Math.max 0, Math.abs(Math.ceil( - @g.zoomer.get('_alignmentScrollLeft') / rectWidth))
    x = - Math.abs( - @g.zoomer.get('_alignmentScrollLeft') % rectWidth)

    res = {rectWidth: rectWidth, rectHeight: rectHeight, y: y}
    elWidth = @el.width

    for j in [start.. seq.length - 1] by 1
      c = seq[j]
      c = c.toUpperCase()

      # call the custom function
      res.x = x
      res.c = c

      # local call is faster than apply
      # http://jsperf.com/function-calls-direct-vs-apply-vs-call-vs-bind/6
      callback @,res

      # move to the right
      x = x + rectWidth

      # out of viewport - stop
      if x > elWidth
        break

  _drawRect: (that, data) ->
    color = that.color[data.c]
    if color?
      that.ctx.fillStyle = color
      that.ctx.fillRect data.x,data.y,data.rectWidth,data.rectHeight

  # REALLY expensive call on FF
  # Performance:
  # chrome: 2000ms drawLetter - 1000ms drawRect
  # FF: 1700ms drawLetter - 300ms drawRect
  _drawLetter: (that,data) ->
    that.ctx.drawImage that.cache.getFontTile(data.c, data.rectWidth,
      data.rectHeight), data.x, data.y,data.rectWidth,data.rectHeight

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

    yZero = data.y

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

  render: ->

    @el.setAttribute 'height', @g.zoomer.get "alignmentHeight"
    @el.setAttribute 'width', @g.zoomer.get "alignmentWidth"

    console.log @g.zoomer.get "alignmentWidth"

    @g.zoomer._adjustWidth @el, @model
    @g.zoomer._checkScrolling( @_checkScrolling([@g.zoomer.get('_alignmentScrollLeft'),
    @g.zoomer.get('_alignmentScrollTop')] ),{header: "canvasseq"})


    @color = colorSelector.getColor @g

    @throttledDraw()
    @

  _onmousemove: (e, reversed) ->
    return if @dragStart.length is 0

    dragEnd = mouse.getMouseCoordsScreen e
    # relative to first click
    relEnd = [dragEnd[0] - @dragStart[0], dragEnd[1] - @dragStart[1]]
    # relative to initial scroll status

    # scale events
    scaleFactor = @g.zoomer.get "canvasEventScale"
    if reversed
      scaleFactor = 3
    for i in [0..1] by 1
      relEnd[i] = relEnd[i] * scaleFactor

    # calculate new scrolling vals
    relDist = [@dragStartScroll[0] - relEnd[0], @dragStartScroll[1] - relEnd[1]]

    # round values
    for i in [0..1] by 1
      relDist[i] = Math.round relDist[i]

    # update scrollbar
    scrollCorrected = @_checkScrolling( relDist)
    @g.zoomer._checkScrolling scrollCorrected, {origin: "canvasseq"}

    # reset start if use scrolls out of bounds
    for i in [0..1] by 1
      if scrollCorrected[i] isnt relDist[i]
        if scrollCorrected[i] is 0
          # reset of left, top
          @dragStart[i] = dragEnd[i]
          @dragStartScroll[i] = 0
        else
          # recalibrate on right, bottom
          @dragStart[i] = dragEnd[i] - scrollCorrected[i]

    @throttledDraw()

    # abort selection events of the browser (mouse only)
    if e.preventDefault?
      e.preventDefault()
      e.stopPropagation()

  # converts touches into old mouse event
  _ontouchmove: (e) ->
    @_onmousemove e.changedTouches[0], true
    e.preventDefault()
    e.stopPropagation()

  # start the dragging mode
  _onmousedown: (e) ->
    @dragStart = mouse.getMouseCoordsScreen e
    @dragStartScroll = [@g.zoomer.get('_alignmentScrollLeft'), @g.zoomer.get('_alignmentScrollTop')]
    jbone(document.body).on 'mousemove.overmove', (e) => @_onmousemove(e)
    jbone(document.body).on 'mouseup.overup', => @_cleanup()
    #jbone(document.body).on 'mouseout.overout', (e) => @_onmousewinout(e)

  # starts the touch mode
  _ontouchstart: (e) ->
    @dragStart = mouse.getMouseCoordsScreen e.changedTouches[0]
    @dragStartScroll = [@g.zoomer.get('_alignmentScrollLeft'), @g.zoomer.get('_alignmentScrollTop')]
    jbone(document.body).on 'touchmove.overtmove', (e) => @_ontouchmove(e)
    jbone(document.body).on 'touchend.overtend touchleave.overtleave
    touchcancel.overtcanel', (e) => @_touchCleanup(e)

  # checks whether mouse moved out of the window
  # -> terminate dragging
  _onmousewinout: (e) ->
    if e.toElement is document.body.parentNode
      @_cleanup()

  # terminates dragging
  _cleanup: ->
    @dragStart = []
    # remove all listeners
    jbone(document.body).off('.overmove')
    jbone(document.body).off('.overup')
    jbone(document.body).off('.overout')

  # terminates touching
  _touchCleanup: (e) ->
    if e.changedTouches.length > 0
      # maybe we can send a final event
      @_onmousemove e.changedTouches[0], true

    @dragStart = []
    # remove all listeners
    jbone(document.body).off('.overtmove')
    jbone(document.body).off('.overtend')
    jbone(document.body).off('.overtleave')
    jbone(document.body).off('.overtcancel')

  # might be incompatible with some browsers
  _onmousewheel: (e) ->
    delta = mouse.getWheelDelta e
    @g.zoomer.set '_alignmentScrollLeft', @g.zoomer.get('_alignmentScrollLeft') + delta[0]
    @g.zoomer.set '_alignmentScrollTop', @g.zoomer.get('_alignmentScrollTop') + delta[1]

  _onclick: (e) ->
    @g.trigger "residue:click", @_getClickPos(e)
    @throttledDraw()

  _onmousein: (e) ->
    @g.trigger "residue:click", @_getClickPos(e)
    @throttledDraw()

  _onmouseout: (e) ->
    @g.trigger "residue:click", @_getClickPos(e)
    @throttledDraw()

  _getClickPos: (e) ->
    coords = mouse.getMouseCoords e
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"
    coords[0] += Math.floor(@g.zoomer.get("_alignmentScrollLeft") / rectWidth) * rectWidth
    coords[1] += Math.floor(@g.zoomer.get("_alignmentScrollTop") / rectHeight) * rectHeight
    x = Math.floor(coords[0] / rectWidth )
    y = Math.floor(coords[1] / rectHeight)
    x = Math.max 0,x
    y = Math.max 0,y
    seqId = @model.at(y).get "id"
    return {seqId:seqId, rowPos: x, evt:e}

  # checks whether the scrolling coordinates are valid
  # @returns: [xScroll,yScroll] valid coordinates
  _checkScrolling: (scrollObj) ->

    # 0: maxLeft, 1: maxTop
    max = [@model.getMaxLength() * @g.zoomer.get("columnWidth") - @g.zoomer.get('alignmentWidth'),
    @model.length  * @g.zoomer.get("rowHeight") - @g.zoomer.get('alignmentHeight')]

    for i in [0..1] by 1
      if scrollObj[i] > max[i]
        scrollObj[i] = max[i]

      if scrollObj[i] < 0
        scrollObj[i] = 0

    return scrollObj

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

  # draws features
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


  # loops over all selection and calls the render method
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

  # draws a single user selection
  _renderSelection: (data) ->

    xZero = data.xZero
    yZero = data.yZero
    n = data.n
    selection = data.selection
    # and checks the prev and next row for selection  -> no borders in a selection
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

  # looks at the selection of the prev and next el
  # TODO: this is very naive, as there might be gaps above or below
  _getPrevNextSelection: (model) ->

    modelPrev = model.collection.prev model
    modelNext = model.collection.next model
    mPrevSel = @_getSelection modelPrev if modelPrev?
    mNextSel = @_getSelection modelNext if modelNext?
    [mPrevSel,mNextSel]
