MarkerView = require "./MarkerView.coffee"
ConservationView = require "./ConservationView"
identityCalc = require "../../algo/identityCalc"
pluginator = require("../../bone/pluginator")

module.exports = pluginator.extend

  initialize: (data) ->
    @g = data.g
    @listenTo @g.vis,"change:markers change:conserv", ->
      @draw()
      @render()
    @listenTo @g.zoomer,"change:alignmentWidth", ->
      @draw()
      @render()

    @draw()

  events:
    "scroll": "_onscroll"

  draw: ->
    @removeViews()

    unless @isNotDirty
      # only executed when new sequences are added or on start
      consensus = @g.consensus.getConsensus @model
      identityCalc @model, consensus
      @isNotDirty = true

    if @g.vis.get "conserv"
      conserv = new ConservationView {model: @model, g: @g}
      conserv.ordering = -20
      @addView "conserv",conserv

    if @g.vis.get "markers"
      marker = new MarkerView {model: @model, g: @g}
      marker.ordering = -10
      @addView "marker",marker

  render: ->
    @renderSubviews()

    # spacer / padding element
    if @g.vis.get "labels"  or @g.vis.get "metacell"
     paddingLeft = 0
     paddingLeft += @g.zoomer.get "labelWidth" if @g.vis.get "labels"
     paddingLeft += @g.zoomer.get "metaWidth" if @g.vis.get "metacell"
     @el.style.marginLeft = paddingLeft

    @el.className = "biojs_msa_header"
    @el.style.overflowX = "auto"
    @el.style.width = @g.zoomer.get "alignmentWidth"
    @

  _onscroll: (e) ->
    @g.zoomer.set "_alignmentScrollLeft", @el.scrollLeft
