pluginator = require("../bone/pluginator")
RowView = require "./RowView"
HeaderView = require "./HeaderView"
ConservationView = require "./ConservationView"

# a neat collection view
DrawView = pluginator.extend

  initialize: (data) ->
    @g = data.g

    @draw()
    @listenTo @model,"sort reset", ->
      @draw()
      @render()

    @listenTo @model,"add", ->
      console.log "seq add"

    @listenTo @g.vis,"change:markers change:conserv", ->
      @draw()
      @render()

  draw: ->
    @removeViews()

    if @g.vis.get "conserv"
      conserv = new ConservationView {model: @model, g: @g}
      conserv.ordering = -20
      @addView "conserv",conserv

    if @g.vis.get "markers"
      header = new HeaderView {model: @model, g: @g}
      header.ordering = -10
      @addView "header",header

    for i in [0.. @model.length - 1] by 1
      view = new RowView {model: @model.at(i), g: @g}
      view.ordering = i
      @addView "row_#{i}", view

  render: ->
    @renderSubviews()
    @

module.exports = DrawView
