_ = require "underscore"

drawer =

  drawLetters: ->

    rectHeight = @rectHeight

    # rects
    @ctx.globalAlpha = @g.colorscheme.get "opacity"
    @drawSeqs (data) -> @drawSeq(data, @_drawRect)
    @ctx.globalAlpha = 1

    # letters
    @drawSeqs (data) -> @drawSeq(data, @_drawLetter)

  drawSeqs: (callback, target) ->
    hidden = @g.columns.get "hidden"

    target = target || @

    [start, y] = @getStartSeq()

    for i in [start.. @model.length - 1] by 1
      seq = @model.at(i)
      continue if seq.get('hidden')
      callback.call target, {model: seq, yPos: y, y: i, hidden: hidden}

      seqHeight = (seq.attributes.height || 1) * @rectHeight
      y = y + seqHeight

      # out of viewport - stop
      if y > @height
        break

  # calls the callback for every drawable row
  drawRows: (callback, target) ->
    @drawSeqs (data) -> @drawRow(data, callback, target)

  # draws a single row
  drawRow: (data, callback, target) ->
    rectWidth = @g.zoomer.get "columnWidth"
    start = Math.max 0, Math.abs(Math.ceil( - @g.zoomer.get('_alignmentScrollLeft') / rectWidth))
    x = - Math.abs( - @g.zoomer.get('_alignmentScrollLeft') % rectWidth)

    xZero = x - start * rectWidth
    yZero = data.yPos
    callback.call target, model: data.model, xZero: xZero, yZero: yZero, hidden: data.hidden

  # returns first sequence in the viewport
  # y is the position to start drawing
  getStartSeq: ->
    start = (Math.max 0, Math.floor( @g.zoomer.get('_alignmentScrollTop') / @rectHeight)) + 1
    counter = 0
    i = 0
    while counter < start and i < @model.length
      counter += @model.at(i).attributes.height || 1
      i++
    y = Math.max(0, @g.zoomer.get('_alignmentScrollTop') - counter * @rectHeight + (@model.at(i - 1)
    .attributes.height  || 1 ) * @rectHeight)
    [i - 1, -y]

  # returns [the clicked seq for a viewport, row number]
  _getSeqForYClick: (click) ->
    [start, yDiff] = @getStartSeq()
    yRel = yDiff % @rectHeight
    clickedRows = (Math.max 0, Math.floor( (click - yRel ) / @rectHeight)) + 1
    counter = 0
    i = start
    while counter < clickedRows and i < @model.length
      counter += @model.at(i).attributes.height || 1
      i++
    rowNumber = Math.max(0, Math.floor(click / @rectHeight) - counter + (@model.at(i - 1).get("height") || 1))
    return [i - 1, rowNumber]

  # TODO: very expensive method
  drawSeq: (data, callback) ->
    seq = data.model.get "seq"
    y = data.yPos
    rectWidth = @rectWidth
    rectHeight = @rectHeight

    # skip unneeded blocks at the beginning
    start = Math.max 0, Math.abs(Math.ceil( - @g.zoomer.get('_alignmentScrollLeft') / rectWidth))
    x = - Math.abs( - @g.zoomer.get('_alignmentScrollLeft') % rectWidth)

    res = {rectWidth: rectWidth, rectHeight: rectHeight, yPos: y, y: data.y}
    elWidth = @width

    for j in [start.. seq.length - 1] by 1
      c = seq[j]
      c = c.toUpperCase()

      # call the custom function
      res.x = j
      res.c = c
      res.xPos = x

      # local call is faster than apply
      # http://jsperf.com/function-calls-direct-vs-apply-vs-call-vs-bind/6
      if data.hidden.indexOf(j) < 0
        callback @,res
      else
        continue

      # move to the right
      x = x + rectWidth

      # out of viewport - stop
      if x > elWidth
        break

  _drawRect: (that, data) ->
    color = that.color.getColor data.c,
      pos:data.x
      y: data.y
    if color?
      that.ctx.fillStyle = color
      that.ctx.fillRect data.xPos,data.yPos,data.rectWidth,data.rectHeight

  # REALLY expensive call on FF
  # Performance:
  # chrome: 2000ms drawLetter - 1000ms drawRect
  # FF: 1700ms drawLetter - 300ms drawRect
  _drawLetter: (that,data) ->
    that.ctx.drawImage that.cache.getFontTile(data.c, data.rectWidth,
      data.rectHeight), data.xPos, data.yPos,data.rectWidth,data.rectHeight


module.exports = construc = (g,ctx,model,opts) ->
  this.g = g
  this.ctx = ctx
  this.model = model
  this.width = opts.width
  this.height = opts.height
  this.color = opts.color
  this.cache = opts.cache
  this.rectHeight = @g.zoomer.get "rowHeight"
  this.rectWidth = @g.zoomer.get "columnWidth"
  @

_.extend construc::, drawer
