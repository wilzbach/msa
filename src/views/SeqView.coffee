view = require("./view")
dom = require("../utils/dom")
svg = require("./svg")
_ = require "underscore"

SeqView = view.extend

  initialize: (data) ->
    @g = data.g
    #@el.setAttribute "class", "biojs-msa-stage-level" + @g.zoomer.level
    @el.setAttribute "class", "biojs-msa-seqblock"
    @_build()

    @listenTo @model, "change:grey", @_build
    @listenTo @g.columns, "change:hidden", @_build
    @listenTo @model, "change:features", @_build
    @listenTo @g.selcol, "add", @_build
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

    @el.style.height = "15px"


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
          #span.style.width= "10px"
          #span.style.height = "15px"
          for f in starts
            span.appendChild @appendFeature f

        if selection[n]?
          span.innerHTML = "x"
          span.style.color = "red"

        @_drawResidue span, seq[n],n
        @el.appendChild span

  render: ->
    @el.className = "biojs_msa_seqblock"
    @el.className += " biojs-msa-schemes-" + @g.colorscheme.get "scheme"
    @

  _onclick: (evt) ->
    #@model.set "selection", @model.get("selection").push(rowPos)
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

  # TODO: experimenting with different views
  appendFeature: (f) ->
    width = (f.get("xEnd") - f.get("xStart")) * 15
    s = svg.base(height: 20, width: width)
    color = '#'+Math.floor(Math.random()*16777215).toString(16)
    s.appendChild svg.rect({x:0,y:0,width:width,height:5,fill: color})
    s.appendChild svg.rect({x:0,y:0,width:width,height:14,style:
      "stroke:red;stroke-width:3;fill-opacity:0;"})
    s.style.position = "absolute"
    $(s).on "mouseover", (evt) =>
      @g.trigger "feature",  f.get("text") + " hovered"
    s

module.exports = SeqView
