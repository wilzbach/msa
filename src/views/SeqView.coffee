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
    @listenTo @g.selcol, "reset", @_build
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
    selection = @_getSelection @model
    cellWidth = @g.zoomer.get "columnWidth"
    # get the status of the upper and lower row
    [mPrevSel,mNextSel] = @_getPrevNextSelection()

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
          span.innerHTML = "&nbsp;"
          for f in starts
            span.appendChild @appendFeature f

        # only if its a new selection
        if selection.indexOf(n) >= 0 and (n is 0 or selection.indexOf(n - 1) < 0 )
          #span.innerHTML = "x"
          span.appendChild @_renderSelection n,selection,mPrevSel,mNextSel
          #span.style.color = "red"
          console.log "render"

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

    console.log @model

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

  _getPrevNextSelection: ->
    # looks at the selection of the prev and next el
    # TODO: this is very naive, as there might be gaps above or below
    modelPrev = @model.collection.prev @model
    modelNext = @model.collection.next @model
    mPrevSel = @_getSelection modelPrev if modelPrev?
    mNextSel = @_getSelection modelNext if modelNext?
    [mPrevSel,mNextSel]

  # displays the current user selection
  # and checks the prev and next row for selection  -> no borders in a selection
  _renderSelection: (n, selection, mPrevSel, mNextSel) ->
    # TODO: this is very, very inefficient
    # get the length of this selection
    selectionLength = 0
    for i in [n.. @model.get("seq").length - 1] by 1
      noTopBorder = true if mPrevSel? and mPrevSel.indexOf(n) >= 0
      noBottomBorder = true if mNextSel? and mNextSel.indexOf(n) >= 0

      if selection.indexOf(i) >= 0
        selectionLength++
      else
        break

    # TODO: ugly!
    width = @g.zoomer.get("columnWidth") * selectionLength
    cHeight = 16
    s = svg.base height: 20, width: width
    s.style.position = "absolute"
    s.style.marginLeft = -12
    y = 1
    y = 3 if noTopBorder
    unless noTopBorder or noBottomBorder
      s.appendChild svg.rect x:0,y:1,width:width,height:cHeight,style:
        "stroke:red;stroke-width:2;fill-opacity:0;"
    else
      s.appendChild svg.line x1:1,y1:1,x2:1,y2:cHeight,style:
        "stroke:red;stroke-width:2;"
      s.appendChild svg.line x1:width - 1,y1:1,x2:width - 1,y2:cHeight,style:
        "stroke:red;stroke-width:2;"
      unless noTopBorder
        s.appendChild svg.line x1:0,y1:1,x2:width,y2:1,style:
          "stroke:red;stroke-width:2;"
      unless noBottomBorder
        s.appendChild svg.line x1:0,y1:cHeight,x2:width,y2:cHeight,style:
          "stroke:red;stroke-width:2;"
    s

  # TODO: experimenting with different views
  # TODO: this is a very naive way of using SVG to display features
  appendFeature: (f) ->
    width = (f.get("xEnd") - f.get("xStart")) * 15
    s = svg.base(height: 20, width: width)
    color = f.get "fillColor"
    s.appendChild svg.rect x:0,y:0,width:width,height:5,fill:color
    s.style.position = "absolute"
    jbone(s).on "mouseover", (evt) =>
      @g.trigger "feature",  f.get("text") + " hovered"
    s

module.exports = SeqView
