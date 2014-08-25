pluginator = require("../bone/pluginator")
AlignmentBody = require "./AlignmentBody"
HeaderBlock = require "./header/HeaderBlock"
OverviewBox = require "./OverviewBox"
identityCalc = require "../algo/identityCalc"
_ = require 'underscore'

# a neat collection view
module.exports = pluginator.extend

  initialize: (data) ->
    @g = data.g

    @draw()
    @listenTo @model,"reset", ->
      @isNotDirty = false
      @rerender()

    # debounce a bulk operation
    @listenTo @model,"change:hidden", _.debounce @rerender, 10

    @listenTo @model,"sort", @rerender
    @listenTo @model,"add", ->
      console.log "seq add"

    @listenTo @g.vis,"change:sequences", @rerender

  draw: ->
    @removeViews()

    unless @isNotDirty
      # only executed when new sequences are added or on start
      consensus = @g.consensus.getConsensus @model
      identityCalc @model, consensus
      @isNotDirty = true

    if @g.vis.get "overviewbox"
      overviewbox = new OverviewBox {model: @model, g: @g}
      overviewbox.ordering = -30
      @addView "overviewbox",overviewbox

    if true
      headerblock = new HeaderBlock {model: @model, g: @g}
      headerblock.ordering = -1
      @addView "headerblock",headerblock

    body = new AlignmentBody {model: @model, g: @g}
    body.ordering = 0
    @addView "body",body

  render: ->
    @renderSubviews()
    @el.className = "biojs_msa_stage"
    @

  rerender: ->
    @draw()
    @render()
