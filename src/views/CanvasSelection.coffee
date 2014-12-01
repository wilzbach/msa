_ = require "underscore"

module.exports = SelectionClass = (g,ctx) ->
  @g = g
  @ctx = ctx
  @

_.extend(SelectionClass::,

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

  # loops over all selection and calls the render method
  _appendSelection: (data) ->
    seq = data.model.get("seq")
    selection = @_getSelection data.model
    # get the status of the upper and lower row
    [mPrevSel,mNextSel] = @_getPrevNextSelection data.model

    boxWidth = @g.zoomer.get("columnWidth")
    boxHeight = @g.zoomer.get("rowHeight")

    # avoid unnecessary loops
    return if selection.length is 0

    hiddenOffset = 0
    for n in [0..seq.length - 1] by 1
      if data.hidden.indexOf(n) >= 0
        hiddenOffset++
      else
        k = n - hiddenOffset
        # only if its a new selection
        if selection.indexOf(n) >= 0 and (k is 0 or selection.indexOf(n - 1) < 0 )
          @_renderSelection n:n,k:k,selection: selection,mPrevSel: mPrevSel,mNextSel:mNextSel, xZero: data.xZero, yZero: data.yZero, model: data.model

  # draws a single user selection
  _renderSelection: (data) ->

    xZero = data.xZero
    yZero = data.yZero
    n = data.n
    k = data.k
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

    xZero += k * boxWidth

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
)
