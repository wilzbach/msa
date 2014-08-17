view = require("./view")
pluginator = require("./pluginator")
RowView = require "./RowView"
HeaderView = require "./HeaderView"

# a neat collection view
DrawView = view.extend

  initialize: (data) ->
    @g = data.g
    @addView "header", new HeaderView {model: @model, g: @g}

    @draw()
    @listenTo @model,"sort", ->
      @draw()
      @render()

    @listenTo @model,"add", ->
      console.log "seq add"
      @draw()
      @render()

  draw: ->
    @removeViews()

    @model.each (seq,i) =>
      view = new RowView {model: seq, g: @g}
      @addView "row #{i}", view

  render: ->
    @renderSubviews()
    @

# mix and shake
pluginator.mixin DrawView::
module.exports = DrawView
