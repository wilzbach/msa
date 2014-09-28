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

  validate: ->
    if isNaN @attributes.xStart or isNaN @attributes.xEnd
      "features need integer start and end."

  contains: (index) ->
    return  @attributes.xStart <= index && index <= @attributes.xEnd

