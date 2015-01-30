boneView = require("backbone-childs")
mouse = require "mouse-pos"
_ = require "underscore"
jbone = require "jbone"
CharCache = require "./CanvasCharCache"
SelectionClass = require "./CanvasSelection"
CanvasSeqDrawer = require "./CanvasSeqDrawer"
CanvasCoordsCache = require "./CanvasCoordsCache"

module.exports = boneView.extend

  tagName: "canvas"

  initialize: (data) ->
    @g = data.g

    @listenTo @g.zoomer, "change:_alignmentScrollLeft change:_alignmentScrollTop", (model,value, options) ->
      if (not options?.origin?) or options.origin isnt "canvasseq"
        @render()

    @listenTo @g.columns,"change:hidden", @render
    @listenTo @g.zoomer,"change:alignmentWidth change:alignmentHeight", @render
    @listenTo @g.colorscheme, "change", @render
    @listenTo @g.selcol, "reset add", @render

    # el props
    @el.style.display = "inline-block"
    @el.style.overflowX = "hidden"
    @el.style.overflowY = "hidden"
    @el.className = "biojs_msa_seqblock"

    @ctx = @el.getContext '2d'
    @cache = new CharCache @g
    @coordsCache = new CanvasCoordsCache @g, @model

    # clear the char cache
    @listenTo @g.zoomer, "change:residueFont", ->
      @cache = new CharCache @g
      @render()

    # init selection
    @sel = new SelectionClass @g,@ctx

    @_setColor()

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
      events.dblclick = "_onclick"
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

  _setColor: ->
    @color = @g.colorscheme.getSelectedScheme()

  draw: ->
    # fastest way to clear the canvas
    # http://jsperf.com/canvas-clear-speed/25
    @el.width = @el.width

    # draw all the stuff
    if @seqDrawer?  and @model.length > 0
      # char based
      @seqDrawer.drawLetters()
      # row based
      @seqDrawer.drawRows @sel._appendSelection, @sel
      @seqDrawer.drawRows @drawFeatures, @

  drawFeatures: (data) ->
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"
    if data.model.attributes.height > 1
      ctx = @ctx
      data.model.attributes.features.each (feature) ->
        ctx.fillStyle = feature.attributes.fillColor || "red"
        len = feature.attributes.xEnd - feature.attributes.xStart + 1
        y = (feature.attributes.row + 1) * rectHeight
        ctx.fillRect feature.attributes.xStart * rectWidth + data.xZero,y + data.yZero,rectWidth * len,rectHeight

      # draw text
      ctx.fillStyle = "black"
      ctx.font = @g.zoomer.get("residueFont") + "px mono"
      ctx.textBaseline = 'middle'
      ctx.textAlign = "center"

      data.model.attributes.features.each (feature) ->
        len = feature.attributes.xEnd - feature.attributes.xStart + 1
        y = (feature.attributes.row + 1) * rectHeight
        ctx.fillText feature.attributes.text, data.xZero + feature.attributes.xStart *
        rectWidth + (len / 2) * rectWidth, data.yZero + rectHeight * 0.5 + y

  render: ->

    @el.setAttribute 'height', @g.zoomer.get("alignmentHeight") + "px"
    @el.setAttribute 'width', @g.zoomer.getAlignmentWidth() + "px"

    @g.zoomer._checkScrolling( @_checkScrolling([@g.zoomer.get('_alignmentScrollLeft'),
    @g.zoomer.get('_alignmentScrollTop')] ),{header: "canvasseq"})

    @_setColor()

    @seqDrawer = new CanvasSeqDrawer @g,@ctx,@model,
      width: @el.width,
      height: @el.height
      color: @color
      cache: @cache

    @throttledDraw()
    @

  _onmousemove: (e, reversed) ->
    return if @dragStart.length is 0

    dragEnd = mouse.abs e
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
    @dragStart = mouse.abs e
    @dragStartScroll = [@g.zoomer.get('_alignmentScrollLeft'), @g.zoomer.get('_alignmentScrollTop')]
    jbone(document.body).on 'mousemove.overmove', (e) => @_onmousemove(e)
    jbone(document.body).on 'mouseup.overup', => @_cleanup()
    #jbone(document.body).on 'mouseout.overout', (e) => @_onmousewinout(e)
    e.preventDefault()

  # starts the touch mode
  _ontouchstart: (e) ->
    @dragStart = mouse.abs e.changedTouches[0]
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
    delta = mouse.wheelDelta e
    @g.zoomer.set '_alignmentScrollLeft', @g.zoomer.get('_alignmentScrollLeft') + delta[0]
    @g.zoomer.set '_alignmentScrollTop', @g.zoomer.get('_alignmentScrollTop') + delta[1]
    e.preventDefault()

  _onclick: (e) ->
    res = @_getClickPos(e)
    if res?
      if res.feature?
        @g.trigger "feature:click", res
      else
        @g.trigger "residue:click", res
    @throttledDraw()

  _onmousein: (e) ->
    res = @_getClickPos(e)
    if res?
      if res.feature?
        @g.trigger "feature:mousein", res
      else
        @g.trigger "residue:mousein", res
    @throttledDraw()

  _onmouseout: (e) ->
    res = @_getClickPos(e)
    if res?
      if res.feature?
        @g.trigger "feature:mouseout", res
      else
        @g.trigger "residue:mouseout", res

    @throttledDraw()

  _getClickPos: (e) ->
    coords = mouse.rel e

    coords[0] += @g.zoomer.get("_alignmentScrollLeft")
    x = Math.floor(coords[0] / @g.zoomer.get("columnWidth") )
    [y,rowNumber] = @seqDrawer._getSeqForYClick(coords[1])

    # add hidden columns
    x += @g.columns.calcHiddenColumns x
    # add hidden seqs
    y += @model.calcHiddenSeqs y

    x = Math.max 0,x
    y = Math.max 0,y

    seqId = @model.at(y).get "id"

    if rowNumber > 0
      # click on a feature
      features = @model.at(y).get("features").getFeatureOnRow(rowNumber - 1, x)
      unless features.length is 0
        feature = features[0]
        console.log features[0].attributes
        return {seqId:seqId, feature: feature, rowPos: x, evt:e}
    else
      # click on a seq
      return {seqId:seqId, rowPos: x, evt:e}

  # checks whether the scrolling coordinates are valid
  # @returns: [xScroll,yScroll] valid coordinates
  _checkScrolling: (scrollObj) ->

    # 0: maxLeft, 1: maxTop
    max = [@coordsCache.maxScrollWidth, @coordsCache.maxScrollHeight]

    for i in [0..1] by 1
      if scrollObj[i] > max[i]
        scrollObj[i] = max[i]

      if scrollObj[i] < 0
        scrollObj[i] = 0

    return scrollObj
