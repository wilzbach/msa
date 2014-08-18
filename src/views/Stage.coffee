view = require("../bone/view")
pluginator = require("../bone/pluginator")
RowView = require "./RowView"
HeaderView = require "./HeaderView"

# a neat collection view
DrawView = view.extend

  initialize: (data) ->
    @g = data.g

    @draw()
    @listenTo @model,"sort", ->
      @draw()
      @render()

    @listenTo @model,"add", ->
      console.log "seq add"

    @listenTo @g.vis,"change:markers", ->
      @draw()
      @render()

  draw: ->
    @removeViews()

    if @g.vis.get "markers"
      header = new HeaderView {model: @model, g: @g}
      header.ordering = -10
      @addView "header",header

    for i in [0.. @model.length - 1] by 1
      console.log @model.at(i).get "name"
      view = new RowView {model: @model.at(i), g: @g}
      view.ordering = i
      @addView "row_#{i}", view

  render: ->
    @renderSubviews()
    @

# mix and shake
pluginator.mixin DrawView::
module.exports = DrawView
