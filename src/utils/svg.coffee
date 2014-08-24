# mini svg helper

svgns = "http://www.w3.org/2000/svg"

setAttr = (obj,opts) ->
  for name, value of opts
    obj.setAttributeNS null, name, value
  obj

Base = (opts) ->
  svg = document.createElementNS svgns, 'svg'
  svg.setAttribute "width", opts.width
  svg.setAttribute "height", opts.height
  svg

Rect = (opts) ->
  rect = document.createElementNS svgns, 'rect'
  setAttr rect,opts

Line = (opts) ->
  line = document.createElementNS svgns, 'line'
  setAttr line,opts

Polygon = (opts) ->
  line = document.createElementNS svgns, 'polygon'
  setAttr line,opts

module.exports.rect = Rect
module.exports.line = Line
module.exports.polygon = Polygon
module.exports.base = Base
