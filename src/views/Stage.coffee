boneView = require("backbone-childs")
AlignmentBody = require "./AlignmentBody"
HeaderBlock = require "./header/HeaderBlock"
OverviewBox = require "./OverviewBox"
Search = require "./Search"
_ = require 'underscore'

# a neat collection view
module.exports = boneView.extend

  initialize: (data) ->
    @g = data.g

    @draw()
    #@listenTo @model,"reset", ->
    # we need to wait until stats gives us the ok
    @listenTo @g.stats,"reset", ->
      @rerender()

    # debounce a bulk operation
    @listenTo @model,"change:hidden", _.debounce @rerender, 10

    @listenTo @model,"sort", @rerender
    @listenTo @model,"add", ->
      console.log "seq add"

    @listenTo @g.vis,"change:sequences", @rerender
    @listenTo @g.vis,"change:overviewbox", @rerender
    @listenTo @g.visorder,"change", @rerender

  draw: ->
    @removeViews()

    if @g.vis.get "overviewbox"
      overviewbox = new OverviewBox {model: @model, g: @g}
      overviewbox.ordering = @g.visorder.get 'overviewBox'
      @addView "overviewBox", overviewbox

    if true
      headerblock = new HeaderBlock {model: @model, g: @g}
      headerblock.ordering = @g.visorder.get 'headerBox'
      @addView "headerBox", headerblock

    if true
      searchblock = new Search {model: @model, g: @g}
      searchblock.ordering = @g.visorder.get 'searchBox'
      @addView "searchbox", searchblock

    body = new AlignmentBody {model: @model, g: @g}
    body.ordering = @g.visorder.get 'alignmentBody'
    @addView "body",body

  render: ->
    @renderSubviews()
    @el.className = "biojs_msa_stage"

    @

  rerender: ->
    @draw()
    @render()
