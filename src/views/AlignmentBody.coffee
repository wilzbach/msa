pluginator = require("../bone/pluginator")
SeqBlock = require "./SeqBlock"
LabelBlock = require "./labels/LabelBlock"

module.exports = pluginator.extend

  initialize: (data) ->
    @g = data.g

    if true
      labelblock = new LabelBlock {model: @model, g: @g}
      labelblock.ordering = -1
      @addView "labelblock",labelblock

    if @g.vis.get "sequences"
      seqblock = new SeqBlock {model: @model, g: @g}
      seqblock.ordering = 0
      @addView "seqblock",seqblock

    @listenTo @g.zoomer, "change:alignmentHeight", @adjustHeight

  render: ->
    @renderSubviews()
    @el.className = "biojs_msa_albody"
    @el.style.overflowY = "auto"
    @el.style.overflowX = "visible"
    # TODO: fix the magic 5
    @el.style.height = (@g.zoomer.get("rowHeight") * @model.length) + 5
    @adjustHeight
    @

  adjustHeight: ->
    @el.style.height = @g.zoomer.get "alignmentHeight"
    # TODO: 15 is the width of the scrollbar
    @el.style.width = @getWidth() + 15

  getWidth: ->
    width = 0
    if @g.vis.get "labels"
      width += @g.zoomer.get "labelWidth"
    if @g.vis.get "metacell"
      width += @g.zoomer.get "metaWidth"
    if @g.vis.get "sequences"
      width += @g.zoomer.get "alignmentWidth"
    width
