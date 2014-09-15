view = require("../bone/view")
mouse = require "../utils/mouse"
selection = require "../g/selection/Selection"
colorSelector = require("biojs-vis-colorschemes").selector
jbone = require "jbone"
_ = require "underscore"

module.exports = OverviewBox = view.extend

  className: "biojs_msa_overviewbox"
  tagName: "canvas"

  initialize: (data) ->
    @g = data.g
    @listenTo @g.zoomer,"change:boxRectWidth change:boxRectHeight", @render
    @listenTo @g.selcol, "add reset change", @render
    @listenTo @g.columns, "change:hidden", @render
    @listenTo @g.colorscheme, "change:showLowerCase", @render
    @listenTo @model, "change", _.debounce @render, 5

    # color
    @color = colorSelector.getColor @g
    @listenTo @g.colorscheme, "change:scheme", ->
      @color = colorSelector.getColor @g
      @render()
    @dragStart = []

  events:
    click: "_onclick"
    mousedown: "_onmousedown"

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

    y = -rectHeight
    for i in [0.. @model.length - 1] by @g.zoomer.attributes.overviewAverageSeqs
      seq = @model.at(i).get "seq"
      x = 0
      y = y + rectHeight


      if @model.at(i).get "hidden"
        # hidden seq
        console.log @model.at(i).get "hidden"
        @ctx.fillStyle = "grey"
        @ctx.fillRect 0,y,seq.length * rectWidth,rectHeight
        continue

      for j in [0.. seq.length - 1] by 1
        c = seq[j]
        # todo: optional uppercasing
        c = c.toUpperCase() if showLowerCase
        color = @color[c]

        if hidden.indexOf(j) >= 0
          color = "grey"

        if color?
          @ctx.fillStyle = color
          @ctx.fillRect x,y,rectWidth,rectHeight

        x = x + rectWidth

    @_drawSelection()

  _drawSelection: ->
    # hide during selection
    return if @dragStart.length > 0 and not @prolongSelection

    rectWidth = @g.zoomer.get "boxRectWidth"
    rectHeight = @g.zoomer.get "boxRectHeight"
    maxHeight = Math.ceil( rectHeight / @g.zoomer.attributes.overviewAverageSeqs) * @model.length
    @ctx.fillStyle = "#ffff00"
    @ctx.globalAlpha = 0.9
    for i in [0.. @g.selcol.length - 1] by @g.zoomer.attributes.overviewAverageSeqs
      sel = @g.selcol.at(i)
      if sel.get('type') is 'column'
        @ctx.fillRect rectWidth * sel.get('xStart'),0,rectWidth *
        (sel.get('xEnd') - sel.get('xStart') + 1),maxHeight
      else if sel.get('type') is 'row'
        seq = (@model.filter (el) -> el.get('id') is sel.get('seqId'))[0]
        pos = @model.indexOf(seq)
        @ctx.fillRect 0,rectHeight * pos, rectWidth * seq.get('seq').length, rectHeight
      else if sel.get('type') is 'pos'
        seq = (@model.filter (el) -> el.get('id') is sel.get('seqId'))[0]
        pos = @model.indexOf(seq)
        @ctx.fillRect rectWidth * sel.get('xStart'),rectHeight * pos, rectWidth * (sel.get('xEnd') - sel.get('xStart') + 1), rectHeight

    @ctx.globalAlpha = 1

  _onclick: (evt) ->
    @g.trigger "meta:click", {seqId: @model.get "id", evt:evt}

  _onmousemove: (e) ->
    # duplicate events
    return if @dragStart.length is 0

    @render()
    @ctx.fillStyle = "#ffff00"
    @ctx.globalAlpha = 0.9

    rect = @_calcSelection( mouse.getMouseCoordsScreen e )
    @ctx.fillRect rect[0][0],rect[1][0],rect[0][1] - rect[0][0], rect[1][1] - rect[1][0]

    # abort selection events of the browser
    e.preventDefault()
    e.stopPropagation()

  # start the selection mode
  _onmousedown: (e) ->
    @dragStart = mouse.getMouseCoordsScreen e
    @dragStartRel = mouse.getMouseCoords e

    if e.ctrlKey or e.metaKey
      @prolongSelection = true
    else
      @prolongSelection = false
    # enable global listeners
    jbone(document.body).on 'mousemove.overmove', (e) => @_onmousemove(e)
    jbone(document.body).on 'mouseup.overup', (e) => @_onmouseup(e)
    return @dragStart

  # calculates the current selection
  _calcSelection: (dragMove) ->
    # relative to first click
    dragRel = [dragMove[0] - @dragStart[0], dragMove[1] - @dragStart[1]]

    # relative to target
    for i in [0..1] by 1
      dragRel[i] = @dragStartRel[i] + dragRel[i]

    # 0:x, 1: y
    rect = [[@dragStartRel[0], dragRel[0]], [@dragStartRel[1], dragRel[1]]]

    # swap the coordinates if needed
    for i in [0..1] by 1
      if rect[i][1] < rect[i][0]
        rect[i] = [rect[i][1], rect[i][0]]

      # lower limit
      rect[i][0] = Math.max rect[i][0], 0

    return rect

  _endSelection: (dragEnd) ->
    # remove listeners
    jbone(document.body).off('.overmove')
    jbone(document.body).off('.overup')

    # duplicate events
    return if @dragStart.length is 0

    rect = @_calcSelection dragEnd

    # x
    for i in [0..1]
      rect[0][i] = Math.floor( rect[0][i] / @g.zoomer.get("boxRectWidth"))
      rect[0][i] = rect[0][i] * @g.zoomer.attributes.overviewAverageSeqs

    # y
    for i in [0..1]
      rect[1][i] = Math.floor( rect[1][i] / @g.zoomer.get("boxRectHeight") )
      rect[1][i] = rect[1][i] * @g.zoomer.attributes.overviewAverageSeqs

    # upper limit
    rect[0][1] = Math.min(@model.getMaxLength() - 1, rect[0][1])
    rect[1][1] = Math.min(@model.length - 1, rect[1][1])


    # select
    selis = []
    for j in [rect[1][0]..rect[1][1]] by 1
      args = seqId: @model.at(j).get('id'), xStart: rect[0][0], xEnd: rect[0][1]
      selis.push new selection.possel args

    # reset
    @dragStart = []
    # look for ctrl key
    if @prolongSelection
      @g.selcol.add selis
    else
      @g.selcol.reset selis

    # safety check + update offset
    @g.zoomer.setLeftOffset rect[0][0]
    @g.zoomer.setTopOffset rect[1][0]

  # ends the selection mode
  _onmouseup: (e) ->
    @_endSelection mouse.getMouseCoordsScreen e

  _onmouseout: (e) ->
    @_endSelection mouse.getMouseCoordsScreen e

 # init the canvas
  _createCanvas: ->
    rectWidth = @g.zoomer.get "boxRectWidth"
    rectHeight = @g.zoomer.get "boxRectHeight"

    @el.height = Math.ceil(@model.length  / @g.zoomer.get("overviewAverageSeqs")) * rectHeight
    @el.width = @model.getMaxLength() * rectWidth
    @ctx = @el.getContext "2d"
    @el.style.overflow = "scroll"
    @el.style.cursor = "crosshair"
