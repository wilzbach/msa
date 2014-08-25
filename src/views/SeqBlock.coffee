SeqView = require("./SeqView")
pluginator = require("../bone/pluginator")

module.exports = pluginator.extend

  initialize: (data) ->
    @g = data.g

    @listenTo @g.zoomer, "change:_alignmentScrollLeft", @_adjustScrollingLeft
    @listenTo @g.columns,"change:hidden", @_adjustWidth
    @listenTo @g.zoomer,"change:alignmentWidth", @_adjustWidth

    @draw()

  draw: ->
    @removeViews()
    for i in [0.. @model.length - 1] by 1
      view = new SeqView {model: @model.at(i), g: @g}
      view.ordering = i
      @addView "row_#{i}", view

  render: ->
    @renderSubviews()
    @el.className = "biojs_msa_seq_st_block"

    @el.style.display = "inline-block"
    @el.style.overflowX = "hidden"
    @el.style.overflowY = "hidden"

    @_adjustWidth()
    @

  _adjustScrollingLeft: ->
    @el.scrollLeft = @g.zoomer.get "_alignmentScrollLeft"


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
