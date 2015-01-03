MarkerView = require "./MarkerView"
ConservationView = require "./ConservationView"
boneView = require("backbone-childs")
_ = require 'underscore'
SeqLogoWrapper = require "./SeqLogoWrapper"
GapView = require "./GapView"

module.exports = boneView.extend

  initialize: (data) ->
    @g = data.g
    @blockEvents = false

    @listenTo @g.vis,"change:header", ->
      @draw()
      @render()
    @listenTo @g.vis,"change", @_setSpacer
    @listenTo @g.zoomer,"change:alignmentWidth", @_setWidth
    @listenTo @g.zoomer, "change:_alignmentScrollLeft", @_adjustScrollingLeft

    # TODO: duplicate rendering
    @listenTo @g.columns, "change:hidden", ->
      @draw()
      @render()

    @draw()

    @g.vis.once 'change:loaded', @_adjustScrollingLeft, @

  events:
    "scroll": "_sendScrollEvent"

  draw: ->
    @removeViews()

    if @g.vis.get "conserv"
      conserv = new ConservationView {model: @model, g: @g}
      conserv.ordering = -20
      @addView "conserv",conserv

    if @g.vis.get "markers"
      marker = new MarkerView {model: @model, g: @g}
      marker.ordering = -10
      @addView "marker",marker

    if @g.vis.get "seqlogo"
      seqlogo = new SeqLogoWrapper {model: @model, g: @g}
      seqlogo.ordering = -30
      @addView "seqlogo",seqlogo

    if @g.vis.get "gapHeader"
      gapview = new GapView {model: @model, g: @g}
      gapview.ordering = -25
      @addView "gapview",gapview

  render: ->
    @renderSubviews()

    @_setSpacer()

    @el.className = "biojs_msa_rheader"
    @el.style.overflowX = "auto"
    @el.style.display = "inline-block"
    @_setWidth()
    @_adjustScrollingLeft()
    @

  # scrollLeft triggers a reflow of the whole area (even only get)
  _sendScrollEvent: ->
    unless @blockEvents
      @g.zoomer.set "_alignmentScrollLeft", @el.scrollLeft, {origin: "header"}
    @blockEvents = false

  _adjustScrollingLeft: (model,value,options) ->
    if (not options?.origin?) or options.origin isnt "header"
      scrollLeft = @g.zoomer.get "_alignmentScrollLeft"
      @blockEvents = true
      @el.scrollLeft = scrollLeft

  _setSpacer: ->
    # spacer / padding element
    @el.style.marginLeft = @_getLabelWidth() + "px"

  _getLabelWidth: ->
    paddingLeft = 0
    unless @g.vis.get "leftHeader"
      paddingLeft += @g.zoomer.getLeftBlockWidth()
    return paddingLeft

  _setWidth: ->
    @el.style.width = @g.zoomer.getAlignmentWidth() + "px"
