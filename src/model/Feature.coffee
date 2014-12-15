Feature = require "./Feature"
Model = require("backbone-thin").Model

module.exports = Feature = Model.extend

  defaults:
    xStart: -1
    xEnd: -1
    height: -1
    text: ""
    fillColor: "red"
    fillOpacity: 0.5
    type: "rectangle"
    borderSize: 1
    borderColor: "black"
    borderOpacity: 0.5
    validate: true
    row: 0

  initialize: (obj) ->
    if obj.start?
      @set "xStart", obj.start
    if obj.end?
      @set "xEnd", obj.end
    # name has a predefined meaning
    if obj.attributes?
      if obj.attributes.Name?
        @set "text", obj.attributes.Name
      if obj.attributes.Color?
        @set "fillColor", obj.attributes.Color

    if @attributes.xEnd < @attributes.xStart
      console.warn "invalid feature range for", @attributes

    if not _.isNumber(@attributes.xStart) or not _.isNumber(@attributes.xEnd)
      console.warn "please provide numeric feature ranges", obj
      # trying auto-casting
      @set "xStart", parseInt(@attributes.xStart)
      @set "xEnd", parseInt(@attributes.xEnd)

  validate: ->
    if isNaN @attributes.xStart or isNaN @attributes.xEnd
      "features need integer start and end."

  contains: (index) ->
    return  @attributes.xStart <= index && index <= @attributes.xEnd

