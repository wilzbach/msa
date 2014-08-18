view = require("../bone/view")
dom = require("../utils/dom")
svg = require("../utils/svg")
_ = require "underscore"
jbone = require "jbone"

# displays the residues
SeqView = view.extend

  initialize: (data) ->
    @g = data.g
    @_build()

    # setup listeners
    @listenTo @model, "change:grey", @_build
    @listenTo @g.columns, "change:hidden", @_build
    @listenTo @model, "change:features", @_build
    @listenTo @g.selcol, "add", @_build
    @listenTo @g.colorscheme,"change", ->
      @_build()
      @render()
    @manageEvents()

  manageEvents: ->
    events = {}
    events.click = "_onclick"
    if @g.config.get "registerMouseEvents"
      events.mousein = "_onmousein"
      events.mouseout = "_onmouseout"
    @delegateEvents events
    @listenTo @g.config, "change:registerMouseEvents", @manageEvents

  _build: ->
    dom.removeAllChilds @el

    seq = @model.get("seq")
    hidden = @g.columns.get "hidden"
    textVisible = @g.zoomer.get "textVisible"
    features = @model.get "features"
    selection = @_getSelection()
    cellWidth = @g.zoomer.get "columnWidth"

    for n in [0..seq.length - 1] by 1
      if hidden.indexOf(n) < 0
        span = document.createElement "span"
        span.rowPos = n
        if textVisible
          span.textContent = seq[n]
        else
          span.innerHTML = "&nbsp;"

        starts = features.startOn n
        if starts.length > 0
          span.innerHTML = "."
          for f in starts
            span.appendChild @appendFeature f

        # only if its a new selection
        if selection[n]? and (n is 0 or !selection[n-1]? )
          #span.innerHTML = "x"
          span.appendChild @_renderSelection n,selection
          #span.style.color = "red"

        @_drawResidue span, seq[n],n
        span.style.width = cellWidth
        @el.appendChild span

  render: ->
    @el.className = "biojs_msa_seqblock"
    if @g.colorscheme.get "colorBackground"
      @el.className += " biojs-msa-schemes-" + @g.colorscheme.get "scheme"
    else
      @el.className += " biojs-msa-schemes-" + @g.colorscheme.get("scheme") +
      "-bl"

  # TODO: remove this boilerplate code for events
  _onclick: (evt) ->
    seqId = @model.get "id"
    @g.trigger "residue:click", {seqId:seqId, rowPos: evt.target.rowPos, evt:evt}

  _onmousein: (evt) ->
    seqId = @model.get "id"
    evt.seqId = seqId
    @g.trigger "residue:mousein", {seqId:seqId, rowPos: evt.target.rowPos, evt:evt}

  _onmouseout: (evt) ->
    seqId = @model.get "id"
    evt.seqId = seqId
    @g.trigger "residue:mousein", {seqId:seqId, rowPos: evt.target.rowPos, evt:evt}

  # sets the properties of a single residue
  _drawResidue: (span,residue,index) ->
    unless @model.get("grey").indexOf(index) >= 0
      span.className = "biojs-msa-aa-" + residue

  # returns an array with the currently selected residues
  # e.g. [0,3] = pos 0 and 3 are selected
  _getSelection: ->
    maxLen = @model.get("seq").length
    selection = new Array maxLen
    sels = @g.selcol.getSelForRow @model.get "id"
    rows = _.find sels, (el) -> el.get("type") is "row"
    if rows?
      # full match
      for n in [0..maxLen - 1] by 1
        selection[n] = 1
    else if sels.length > 0
      for sel in sels
        for n in [sel.get("xStart")..sel.get("xEnd")] by 1
          selection[n] = 1

    return selection

  _renderSelection: (n, selection) ->
    selectionLength = 0
    # TODO: this is very, very inefficient
    for i in [n.. @model.get("seq").length - 1] by 1
      if selection[i]?
        selectionLength++
      else
        break

    width = @g.zoomer.get("columnWidth") * selectionLength
    s = svg.base(height: 20, width: width)
    s.style.position = "absolute"
    s.style.marginLeft = -12
    s.appendChild svg.rect({x:0,y:1,width:width,height:14,style:
      "stroke:red;stroke-width:2;fill-opacity:0;"})
    s

  # TODO: experimenting with different views
  # TODO: this is a very naive way of using SVG to display features
  appendFeature: (f) ->
    width = (f.get("xEnd") - f.get("xStart")) * 15
    s = svg.base(height: 20, width: width)
    color = f.get "fillColor"
    s.appendChild svg.rect({x:0,y:0,width:width,height:5,fill: color})
    s.style.position = "absolute"
    jbone(s).on "mouseover", (evt) =>
      @g.trigger "feature",  f.get("text") + " hovered"
    s

module.exports = SeqView
