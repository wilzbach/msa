_ = require "underscore"
Events = require "biojs-events"

cache =

  setMaxScrollHeight: ->
    @maxScrollHeight = @g.zoomer.getMaxAlignmentHeight() - @g.zoomer.get('alignmentHeight')

  setMaxScrollWidth: ->
    @maxScrollWidth = @g.zoomer.getMaxAlignmentWidth() - @g.zoomer.getAlignmentWidth()

module.exports = cacheConstructor = (g,model) ->
  this.g = g
  this.model = model
  @setMaxScrollHeight()
  @setMaxScrollWidth()

  @listenTo @g.zoomer, "change:rowHeight", @setMaxScrollHeight
  @listenTo @g.zoomer, "change:columnWidth", @setMaxScrollWidth
  @listenTo @g.zoomer, "change:alignmentWidth", @setMaxScrollWidth
  @listenTo @g.zoomer, "change:alignmentHeight", @setMaxScrollHeight
  @listenTo @model, "add change reset", ->
    @setMaxScrollHeight()
    @setMaxScrollWidth()
  , @
  @

_.extend cacheConstructor::, cache
Events.mixin cacheConstructor::
