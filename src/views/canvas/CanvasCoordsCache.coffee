_ = require "underscore"
Events = require "biojs-events"

cache =

  setMaxScrollHeight: ->
    height = 0
    @model.each (seq) ->
      height += seq.attributes.height || 1

    @maxScrollHeight = (height * @g.zoomer.get("rowHeight")) - @g.zoomer.get('alignmentHeight')

  setMaxScrollWidth: ->
    @maxScrollWidth = @model.getMaxLength() * @g.zoomer.get("columnWidth") - @g.zoomer.get('alignmentWidth')


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
