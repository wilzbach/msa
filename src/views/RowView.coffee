view = require("../bone/view")
pluginator = require("../bone/pluginator")
LabelView = require("./LabelView")
SeqView = require("./SeqView")

RowView = view.extend

  initialize: (data) ->
    @g = data.g
    @el.setAttribute "class", "biojs_msa_layer"
    @addView "seqs", new SeqView {model: @model, g:@g}
    @addView "labels", new LabelView {model: @model, g:@g}

    @listenTo @g.colorscheme,"change",@render

  render: ->
    @renderSubviews()
    @

#    # TODO: fix me
#    @msa.on "row:select", (data) =>
#      rowGroup = data.target
#      rowGroup.className = "biojs_msa_seqblock"
#      rowGroup.className += " biojs-msa-schemes-" + @scheme


# mix and shake
pluginator.mixin RowView::
module.exports = RowView
