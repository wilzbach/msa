view = require("../bone/view")
mouse = require "../utils/mouse"
selection = require "../g/selection/Selection"
TaylorColors = require "./color/taylor"
ZappoColors = require "./color/zappo"
HydroColors = require "./color/hydrophobicity"

module.exports = OverviewBox = view.extend

  className: "biojs_msa_overviewbox"
  tagName: "canvas"

  initialize: (data) ->
    @g = data.g
    @listenTo @g.zoomer,"change:boxRectWidth change:boxRectHeight", @render
    @listenTo @g.selcol, "add reset change", @render
    @listenTo @g.columns, "change:hidden", @render
    @listenTo @g.colorscheme, "change:showLowerCase", @render

    # color
    @_setColorScheme()
    @listenTo @g.colorscheme, "change:scheme", ->
      @_setColorScheme()
      @render()
    @dragStart = []

  events:
    click: "_onclick"
    mousedown: "_onmousedown"
    mouseup: "_onmouseup"
    mouseout: "_onmouseout"
    mousemove: "_onmousemove"

  render: ->
    @_createCanvas()
    @el.textContent = "overview"

    # background bg for non-drawed area
    @ctx.fillStyle = "#999999"
    @ctx.fillRect 0,0,@el.width,@el.height

    rectWidth = @g.zoomer.get "boxRectWidth"
    rectHeight = @g.zoomer.get "boxRectHeight"
    hidden = @g.columns.get "hidden"
    showLowerCase = @g.colorscheme.get "showLowerCase"

    y = 0
    for i in [0.. @model.length - 1] by 1
      seq = @model.at(i).get "seq"
      x = 0
      for j in [0.. seq.length - 1] by 1
        c = seq[j]
        # todo: optional uppercasing
        c = c.toUpperCase() if showLowerCase
        color = @color[c]

        if hidden.indexOf(j) >= 0
          @ctx.globalAlpha = 0.3
        else
          @ctx.globalAlpha = 1 if @ctx.globalAlpha isnt 1

        if color?
          @ctx.fillStyle = "#" + color
          @ctx.fillRect x,y,rectWidth,rectHeight
        x = x + rectWidth
      y = y + rectHeight

    @_drawSelection()

  _drawSelection: ->
    # hide during selection
    return if @dragStart.length > 0 and not @prolongSelection

    rectWidth = @g.zoomer.get "boxRectWidth"
    rectHeight = @g.zoomer.get "boxRectHeight"
    maxHeight = rectHeight * @model.length
    @ctx.fillStyle = "#ffff00"
    @ctx.strokeStyle = "#000000"
    @ctx.lineWidth = 2
    @ctx.globalAlpha = 1

    for i in [0.. @g.selcol.length - 1] by 1
      sel = @g.selcol.at(i)
      if sel.get('type') is 'column'
        @ctx.strokeRect rectWidth * sel.get('xStart'),0,rectWidth *
        (sel.get('xEnd') - sel.get('xStart') + 1),maxHeight
      else if sel.get('type') is 'row'
        seq = (@model.filter (el) -> el.get('id') is sel.get('seqId'))[0]
        pos = @model.indexOf(seq)
        @ctx.strokeRect 0,rectHeight * pos, rectWidth * seq.get('seq').length, rectHeight
      else if sel.get('type') is 'pos'
        seq = (@model.filter (el) -> el.get('id') is sel.get('seqId'))[0]
        pos = @model.indexOf(seq)
        @ctx.strokeRect rectWidth * sel.get('xStart'),rectHeight * pos, rectWidth * (sel.get('xEnd') - sel.get('xStart') + 1), rectHeight

  _onclick: (evt) ->
    @g.trigger "meta:click", {seqId: @model.get "id", evt:evt}

  _onmousemove: (e) ->
    # duplicate events
    return if @dragStart.length is 0

    @dragEnd = mouse.getMouseCoords e
    @render()
    @ctx.fillStyle = "#ffff00"
    @ctx.globalAlpha = 0.5
    @ctx.fillRect @dragStart[0],@dragStart[1],@dragEnd[0] - @dragStart[0], @dragEnd[1] - @dragStart[1]

  # start the selection mode
  _onmousedown: (e) ->
    @dragStart = arr = mouse.getMouseCoords e
    if e.ctrlKey or e.metaKey
      @prolongSelection = true
    else
      @prolongSelection = false
    return @dragStart

  _endSelection: (dragEnd) ->
    # duplicate events
    return if @dragStart.length is 0

    rectWidth = @g.zoomer.get "boxRectWidth"
    rectHeight = @g.zoomer.get "boxRectHeight"

    a = new Array 4
    a[0] = Math.min @dragStart[0],dragEnd[0]
    a[1] = Math.min @dragStart[1],dragEnd[1]
    a[2] = Math.max @dragStart[0],dragEnd[0]
    a[3] = Math.max @dragStart[1],dragEnd[1]

    # round
    for i in [0..3]
      if i % 2 is 0 # x
        a[i] = Math.floor( a[i] / rectWidth)
      else # y
        a[i] = Math.floor( a[i] / rectHeight)
      if i <= 1 #dragStart
        a[i] = Math.max 0, a[i]
    a[2] = Math.min @model.getMaxLength(), a[2]
    a[3] = Math.min @model.length - 1, a[3]

    # select
    selis = []
    for j in [a[1]..a[3]] by 1
      args = seqId: @model.at(j).get('id'), xStart: a[0], xEnd: a[2]
      selis.push new selection.possel args

    # reset
    @dragStart = []
    # look for ctrl key
    if @prolongSelection
      @g.selcol.add selis
    else
      @g.selcol.reset selis

  # ends the selection mode
  _onmouseup: (e) ->
    @_endSelection mouse.getMouseCoords e

  _onmouseout: (e) ->
    @_endSelection mouse.getMouseCoords e


  _setColorScheme: ->
    scheme = @g.colorscheme.get "scheme"

    if scheme is "taylor"
      @color = TaylorColors
    else if scheme  is "zappo"
      @color = ZappoColors
    else if scheme is "hydrophobicity"
      @color = HydroColors
    else
      console.log "warning. no color scheme found."

 # init the canvas
  _createCanvas: ->
    rectWidth = @g.zoomer.get "boxRectWidth"
    rectHeight = @g.zoomer.get "boxRectHeight"

    @el.height = @model.length * rectHeight
    @el.width = @model.getMaxLength() * rectWidth
    @ctx = @el.getContext "2d"
    @el.style.overflow = "scroll"
    @el.style.cursor = "crosshair"
