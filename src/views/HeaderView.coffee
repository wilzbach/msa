view = require("../bone/view")
dom = require("../utils/dom")

HeaderView = view.extend

  className: "biojs_msa_marker"

  initialize: (data) ->
    @g = data.g
    @listenTo @g.zoomer,"change:stepSize", @render
    @listenTo @g.zoomer,"change:labelOffset:", @render
    @listenTo @g.vis,"change:labels", @render
    @manageEvents()

  render: ->
    dom.removeAllChilds @el
    if @g.vis.get "labels"
      # padding el
      spacer = document.createElement "span"
      spacer.innerHTML = "&nbsp;"
      spacer.style.display = "block"
      spacer.style.float = "left"
      spacer.style.width = @g.zoomer.get "labelOffset"
      @el.appendChild spacer

    container = document.createElement "span"
    #container.style.display = "in"
    n = 0
    cellWidth = @g.zoomer.get "columnWidth"

    nMax = @model.getMaxLength()
    console.log "nmax", nMax
    stepSize = @g.zoomer.get("stepSize")

    while n < nMax
      span = document.createElement "span"
      span.style.width = cellWidth * stepSize
      span.style.display = "inline-block"
      span.textContent = n
      span.rowPos = n
      #span.style.flexGrow = 1

      n +=stepSize
      container.appendChild span

    @el.appendChild container
    @

  manageEvents: ->
    events = {}
    events.click = "_onclick"
    if @g.config.get "registerMouseEvents"
      events.mousein = "_onmousein"
      events.mouseout = "_onmouseout"
    @delegateEvents events
    @listenTo @g.config, "change:registerMouseEvents", @manageEvents

  _onclick: (evt) ->
    rowPos = evt.target.rowPos
    stepSize = @g.zoomer.get("stepSize")
    # simulate hidden columns
    for i in [0..stepSize - 1] by 1
      @g.trigger "column:click", {rowPos: rowPos + i, evt:evt}

  _onmousein: (evt) ->
    rowPos = @g.zoomer.get "stepSize" * evt.rowPos
    @g.trigger "column:mousein", {rowPos: rowPos, evt:evt}

  _onmouseout: (evt) ->
    rowPos = @g.zoomer.get "stepSize" * evt.rowPos
    @g.trigger "column:mouseout", {rowPos: rowPos, evt:evt}

module.exports = HeaderView
