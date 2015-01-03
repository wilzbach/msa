boneView = require("backbone-childs")
LabelView = require("./LabelView")
MetaView = require("./MetaView")

module.exports = boneView.extend

  initialize: (data) ->
    @g = data.g
    @draw()

    @listenTo @g.vis,"change:labels", @drawR
    @listenTo @g.vis,"change:metacell", @drawR
    @listenTo @g.zoomer, "change:rowHeight", ->
      @el.style.height = @g.zoomer.get("rowHeight") + "px"

    @listenTo @g.selcol,"change reset add", @setSelection

  draw: ->
    @removeViews()
    if @g.vis.get "labels"
      @addView "labels", new LabelView {model: @model, g:@g}
    if @g.vis.get "metacell"
      meta = new MetaView {model: @model, g:@g}
      @addView "metacell", meta

  drawR: ->
    @draw()
    @render()

  render: ->
    @renderSubviews()

    @el.setAttribute "class", "biojs_msa_labelrow"
    @el.style.height = @g.zoomer.get("rowHeight") * (@model.attributes.height || 1) + "px"

    @setSelection()
    @

  setSelection: ->
    sel = @g.selcol.getSelForRow @model.id
    if sel.length > 0
      @el.style.fontWeight = "bold"
    else
      @el.style.fontWeight = "normal"
