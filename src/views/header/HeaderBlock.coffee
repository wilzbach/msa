boneView = require("backbone-childs")
LabelHeader = require "./LabelHeader"
RightLabelHeader = require "./RightHeaderBlock"

module.exports = boneView.extend

  initialize: (data) ->
    @g = data.g
    @draw()
    @listenTo @g.vis,"change:labels change:metacell change:leftHeader", =>
      @draw()
      @render()

  draw: ->
    @removeViews()

    if @g.vis.get("leftHeader") and (@g.vis.get("labels") or @g.vis.get("metacell"))
      lHeader = new LabelHeader {model: @model, g: @g}
      lHeader.ordering = -50
      @addView "lHeader", lHeader

    rHeader = new RightLabelHeader {model: @model, g: @g}
    rHeader.ordering = 0
    @addView "rHeader", rHeader

  render: ->
    @renderSubviews()

    @el.className = "biojs_msa_header"
