view = require("../../bone/view")
dom = require("../../utils/dom")
svg = require("../../utils/svg")

ConservationView = view.extend

  className: "biojs_msa_conserv"

  initialize: (data) ->
    @g = data.g
    @listenTo @g.zoomer,"change:stepSize change:labelWidth change:columnWidth", @render
    @listenTo @g.vis,"change:labels change:metacell", @render
    @listenTo @g.columns, "change:scaling", @render
    @listenTo @model, "reset",@render
    @manageEvents()

  render: ->
    @g.columns.calcConservation @model

    dom.removeAllChilds @el

    nMax = @model.getMaxLength()
    cellWidth = @g.zoomer.get "columnWidth"
    maxHeight = 20
    width = cellWidth * (nMax - @g.columns.get('hidden').length)
    s = svg.base height: maxHeight, width: width
    s.style.display = "inline-block"
    s.style.cursor = "pointer"

    stepSize = @g.zoomer.get "stepSize"
    hidden = @g.columns.get "hidden"
    x = 0
    n = 0
    while n < nMax
      if hidden.indexOf(n) >= 0
        n += stepSize
        continue
      width = cellWidth * stepSize
      avgHeight = 0
      for i in [0 .. stepSize - 1]
        avgHeight += @g.columns.get("conserv")[n]
      height = maxHeight *  (avgHeight / stepSize)

      rect =  svg.rect x:x,y: maxHeight - height,width:width - cellWidth / 4,height:height,style:
        "stroke:red;stroke-width:1;"
      rect.rowPos = n
      s.appendChild rect
      x += width
      n += stepSize

    @el.appendChild s
    @

  #TODO: make more general with HeaderView
  _onclick: (evt) ->
    rowPos = evt.target.rowPos
    stepSize = @g.zoomer.get("stepSize")
    # simulate hidden columns
    for i in [0..stepSize - 1] by 1
      @g.trigger "bar:click", {rowPos: rowPos + i, evt:evt}

  manageEvents: ->
    events = {}
    events.click = "_onclick"
    if @g.config.get "registerMouseEvents"
      events.mousein = "_onmousein"
      events.mouseout = "_onmouseout"
    @delegateEvents events
    @listenTo @g.config, "change:registerMouseEvents", @manageEvents

  _onmousein: (evt) ->
    rowPos = @g.zoomer.get "stepSize" * evt.rowPos
    @g.trigger "bar:mousein", {rowPos: rowPos, evt:evt}

  _onmouseout: (evt) ->
    rowPos = @g.zoomer.get "stepSize" * evt.rowPos
    @g.trigger "bar:mouseout", {rowPos: rowPos, evt:evt}

module.exports = ConservationView
