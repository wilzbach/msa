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
      @addView "header", new HeaderView {model: @model, g: @g}

    @model.each (seq,i) =>
      view = new RowView {model: seq, g: @g}
      @addView "row #{i}", view

  render: ->
    @renderSubviews()
    @

# mix and shake
pluginator.mixin DrawView::
module.exports = DrawView
