view = require("./view")
pluginator = require("./pluginator")
LabelView = require("./LabelView")
SeqView = require("./SeqView")

RowView = view.extend

  initialize: (data) ->
    @seq = data.seq
    @g = data.g
    @el.setAttribute "class", "biojs_msa_layer"
    @addView "seqs", new SeqView {seq: data.seq, g:@g}
    @addView "labels", new LabelView {seq: data.seq, g:@g}

  render: ->
    @renderSubviews()
    @

# mix and shake
pluginator.mixin RowView::
module.exports = RowView
