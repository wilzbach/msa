# mini svg helper

svgns = "http://www.w3.org/2000/svg"

Base = (opts) ->
  svg = document.createElementNS svgns, 'svg'
  svg.setAttribute "width", opts.width
  svg.setAttribute "height", opts.height
  svg

Rect = (opts) ->
  rect = document.createElementNS svgns, 'rect'
  for name, value of opts
    rect.setAttributeNS null, name, value
  rect

module.exports.rect = Rect
module.exports.base = Base
