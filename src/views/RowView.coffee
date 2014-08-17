view = require("../bone/view")
pluginator = require("../bone/pluginator")
LabelView = require("./LabelView")
SeqView = require("./SeqView")

RowView = view.extend

  initialize: (data) ->
    @g = data.g
    @el.setAttribute "class", "biojs_msa_layer"
    @draw()

    @listenTo @g.colorscheme,"change",@render
    @listenTo @g.vis,"change:labels", @drawR
    @listenTo @g.vis,"change:sequences", @drawR

  draw: ->
    @removeViews()
    if @g.vis.get "labels"
      @addView "labels", new LabelView {model: @model, g:@g}
    if @g.vis.get "sequences"
      @addView "seqs", new SeqView {model: @model, g:@g}

  drawR: ->
    @draw()
    @render()

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
