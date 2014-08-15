view = require("./view")
pluginator = require("./pluginator")
RowView = require "./RowView"
HeaderView = require "./HeaderView"

DrawView = view.extend

  initialize: (data) ->
    @addView "header", new HeaderView {seq: seq, g: data.g}
    for i,seq of data.seqs
      view = new RowView {seq: seq, g: data.g}
      @addView "row #{i}", view

  render: ->
    @renderSubviews()
    @

# mix and shake
pluginator.mixin DrawView::
module.exports = DrawView
