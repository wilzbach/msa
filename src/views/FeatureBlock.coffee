
  # draws features
  appendFeature: (data) ->
    f = data.f
    # TODO: this is a very naive way
    boxWidth = @g.zoomer.get("columnWidth")
    boxHeight = @g.zoomer.get("rowHeight")
    width = (f.get("xEnd") - f.get("xStart")) * boxWidth

    beforeWidth = @ctx.lineWidth
    @ctx.lineWidth = 3
    beforeStyle = @ctx.strokeStyle
    @ctx.strokeStyle = f.get "fillColor"

    @ctx.strokeRect data.xZero, data.yZero, width,boxHeight
    @ctx.strokeStyle = beforeStyle
    @ctx.lineWidth = beforeWidth

  drawFeature: (data) ->
    seq = data.model.get "seq"
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"

    start = Math.max 0, Math.abs(Math.ceil( - @g.zoomer.get('_alignmentScrollLeft') / rectWidth))
    x = - Math.abs( - @g.zoomer.get('_alignmentScrollLeft') % rectWidth)
    xZero = x - start * rectWidth

    features = data.model.get "features"

    yZero = data.y

    for j in [start.. seq.length - 1] by 1
      starts = features.startOn j

      if data.hidden.indexOf(j) >= 0
        continue

      if starts.length > 0
        for f in starts
          @appendFeature f: f,xZero: x, yZero: yZero

      x = x + rectWidth
      # out of viewport - stop
      if x > @el.width
        break
