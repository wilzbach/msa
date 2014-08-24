SeqView = require("./SeqView")
pluginator = require("../bone/pluginator")

module.exports = pluginator.extend

  initialize: (data) ->
    @g = data.g

    @listenTo @g.zoomer, "change:_alignmentScrollLeft", @adjustScrollingLeft
    @listenTo @g.zoomer,"change:alignmentWidth", ->
      @draw()
      @render()

    @draw()

  draw: ->
    @removeViews()
    for i in [0.. @model.length - 1] by 1
      view = new SeqView {model: @model.at(i), g: @g}
      view.ordering = i
      @addView "row_#{i}", view



  render: ->
    @renderSubviews()
    @el.className = "biojs_msa_seq_st_block"

    @el.style.display = "inline-block"
    @el.style.overflowX = "hidden"
    @el.style.overflowY = "hidden"
    @el.style.width = @g.zoomer.get "alignmentWidth"
    @

  adjustScrollingLeft: ->
    @el.scrollLeft = @g.zoomer.get "_alignmentScrollLeft"
