SeqView = require("./SeqView")
pluginator = require("../bone/pluginator")
TaylorColors = require "./color/taylor"
ZappoColors = require "./color/zappo"
HydroColors = require "./color/hydrophobicity"

module.exports = pluginator.extend

  tagName: "canvas"

  initialize: (data) ->
    @g = data.g

    @listenTo @g.zoomer, "change:_alignmentScrollLeft change:_alignmentScrollTop", @render
    @listenTo @g.columns,"change:hidden", @_adjustWidth
    @listenTo @g.zoomer,"change:alignmentWidth", @_adjustWidth

    @ctx = @el.getContext '2d'

    @color = TaylorColors
    @el.setAttribute 'height', @g.zoomer.get "alignmentHeight"
    @el.style.height =  @g.zoomer.get "alignmentHeight"

    #@el.setAttribute 'width', 300
    #@el.style.width = 300

  draw: ->
    @removeViews()

    y = - @g.zoomer.get "_alignmentScrollTop"

    rectHeight = @g.zoomer.get "rowHeight"
    @ctx.globalAlpha = 1
    for i in [0.. @model.length - 1] by 1
      continue if @model.at(i).get('hidden')
      @drawSeq {model: @model.at(i), y: y}
      #view = new SeqView {model: @model.at(i), g: @g}
      y = y + rectHeight

      # out of viewport - stop
      if y > @el.height
        break

  drawSeq: (data) ->
    seq = data.model.get "seq"
    y = data.y
    rectWidth = @g.zoomer.get "columnWidth"
    rectHeight = @g.zoomer.get "rowHeight"

    @ctx.font="14px Courier New"
    #@ctx.font="14px Lucida Console"

    x = 0
    x = - @g.zoomer.get "_alignmentScrollLeft"
    for j in [0.. seq.length - 1] by 1
      c = seq[j]
      c = c.toUpperCase()
      color = @color[c]
      if color?
        @ctx.fillStyle = "#" + color
        @ctx.fillRect x,y,rectWidth,rectHeight
        @ctx.strokeText c,x + 3,y + 12,rectWidth
      x = x + rectWidth

      # out of viewport - stop
      if x > @el.width
        break

  render: ->


    @el.className = "biojs_msa_seq_st_block"
    @el.style.display = "inline-block"
    @el.style.overflowX = "hidden"
    @el.style.overflowY = "hidden"

    @_adjustWidth()
    @draw()

    @

  _getLabelWidth: ->
     paddingLeft = 0
     paddingLeft += @g.zoomer.get "labelWidth" if @g.vis.get "labels"
     paddingLeft += @g.zoomer.get "metaWidth" if @g.vis.get "metacell"
     return paddingLeft

  _adjustWidth: ->
    if @el.parentNode?
      parentWidth = @el.parentNode.offsetWidth
    else
      parentWidth = document.body.clientWidth

    # TODO: dirty hack
    @maxWidth = parentWidth - @_getLabelWidth() - 35
    @el.style.width = @g.zoomer.get "alignmentWidth"
    calcWidth = @g.zoomer.getAlignmentWidth( @model.getMaxLength() - @g.columns.get('hidden').length)
    if calcWidth > @maxWidth
      @g.zoomer.set "alignmentWidth", @maxWidth
    @el.style.width = Math.min calcWidth, @maxWidth
    @el.setAttribute 'width', @el.style.width
