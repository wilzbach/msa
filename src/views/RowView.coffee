pluginator = require("../bone/pluginator")
LabelView = require("./LabelView")
MetaView = require("./MetaView")
SeqView = require("./SeqView")

RowView = pluginator.extend

  initialize: (data) ->
    @g = data.g
    @draw()

    @listenTo @g.vis,"change:labels", @drawR
    @listenTo @g.vis,"change:sequences", @drawR
    @listenTo @g.vis,"change:metacell", @drawR

  draw: ->
    @removeViews()
    if @g.vis.get "labels"
      @addView "labels", new LabelView {model: @model, g:@g}
    if @g.vis.get "metacell"
      @addView "metacell", new MetaView {model: @model, g:@g}
    if @g.vis.get "sequences"
      @addView "seqs", new SeqView {model: @model, g:@g}

  drawR: ->
    @draw()
    @render()

  render: ->
    @renderSubviews()
    @el.setAttribute "class", "biojs_msa_layer"
    @el.style.height = @g.zoomer.get "rowHeight"
    @

#    # TODO: fix me
#    @msa.on "row:select", (data) =>
#      rowGroup = data.target
#      rowGroup.className = "biojs_msa_seqblock"
#      rowGroup.className += " biojs-msa-schemes-" + @scheme

module.exports = RowView
