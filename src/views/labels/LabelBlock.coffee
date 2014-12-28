LabelRowView = require "./LabelRowView"
boneView = require("backbone-childs")

module.exports = boneView.extend

  initialize: (data) ->
    @g = data.g
    @draw()
    @listenTo @g.zoomer, "change:_alignmentScrollTop", @_adjustScrollingTop
    @g.vis.once 'change:loaded', @_adjustScrollingTop , @

    @listenTo @g.zoomer,"change:alignmentHeight", @_setHeight

  draw: ->
    @removeViews()
    for i in [0.. @model.length - 1] by 1
      continue if @model.at(i).get('hidden')
      view = new LabelRowView {model: @model.at(i), g: @g}
      view.ordering = i
      @addView "row_#{i}", view

  events:
    "scroll": "_sendScrollEvent"

  # broadcast the scrolling event (by the scrollbar)
  _sendScrollEvent: ->
    @g.zoomer.set "_alignmentScrollTop", @el.scrollTop, {origin: "label"}

  # sets the scrolling property (from another event e.g. dragging)
  _adjustScrollingTop: ->
    @el.scrollTop =  @g.zoomer.get "_alignmentScrollTop"

  render: ->
    @renderSubviews()
    @el.className = "biojs_msa_labelblock"
    @el.style.display = "inline-block"
    @el.style.verticalAlign = "top"
    @el.style.overflowY = "auto"
    @el.style.overflowX = "hidden"
    @el.style.fontSize = "#{@g.zoomer.get "labelFontsize"}"
    @el.style.lineHeight = "#{@g.zoomer.get "labelLineHeight"}"
    @_setHeight()
    @


  _setHeight: ->
    @el.style.height = @g.zoomer.get("alignmentHeight") + "px"
