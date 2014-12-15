Feature = require "./Feature"
Collection = require("backbone-thin").Collection
_ = require "underscore"

module.exports = FeatureCol = Collection.extend
  model: Feature

  constructor: ->
    @startOnCache = []
    # invalidate cache
    @on "all", ->
      @startOnCache = []
    , @
    Collection.apply @, arguments

  # returns all features starting on index
  startOn: (index) ->
    unless @startOnCache[index]?
      @startOnCache[index] = @where({xStart: index})
    return @startOnCache[index]

  contains: (index) ->
    @reduce (el,memo) ->
      memo || el.contains index
    , false

  # tries to auto-fit the rows
  # not a very efficient algorithm
  assignRows: ->

    len = (@max (el) -> el.get("xEnd")).attributes.xEnd
    rows = (0 for x in [0.. len])

    @each (el) ->
      max = 0
      for x in [el.get("xStart") .. el.get("xEnd")] by 1
        if rows[x] > max
          max = rows[x]
        rows[x]++
      el.set("row", max)

    _.max rows

  getCurrentHeight: ->
    (@max (el) -> el.get("row")).attributes.row + 1

  # gives the minimal needed number of rows
  # not a very efficient algorithm
  # (there is one in O(n) )
  getMinRows: ->

    len = (@max (el) -> el.get("xEnd")).attributes.xEnd
    rows = (0 for x in [0.. len])

    @each (el) ->
      for x in [el.get("xStart") .. el.get("xEnd")] by 1
        rows[x]++

    _.max rows
