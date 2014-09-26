pluginator = require("backbone-childs")
LabelView = require("./LabelView")
MetaView = require("./MetaView")

module.exports = pluginator.extend

  initialize: (data) ->
    @g = data.g
    @draw()

    @listenTo @g.vis,"change:labels", @drawR
    @listenTo @g.vis,"change:metacell", @drawR

  draw: ->
    @removeViews()
    if @g.vis.get "labels"
      @addView "labels", new LabelView {model: @model, g:@g}
    if @g.vis.get "metacell"
      @addView "metacell", new MetaView {model: @model, g:@g}

  drawR: ->
    @draw()
    @render()

  render: ->
    @renderSubviews()
    @el.setAttribute "class", "biojs_msa_labelrow"
    @el.style.height = @g.zoomer.get "rowHeight"
    @
