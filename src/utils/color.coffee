Utils = {}

#
# * renders the color string nicely
#
Utils.rgb = (r, g, b) ->

  # we use the overloaded, shorthand form (color)
  return Utils.rgb(r.r, r.g, r.b)  if typeof g is "undefined"
  [
    "rgb("
    [
      r or 0
      g or 0
      b or 0
    ].join(",")
    ")"
  ].join()

Utils.rgba = (r, g, b, a) ->

  # we use the overloaded, shorthand form (color, a)
  return Utils.rgba(r.r, r.g, r.b, g)  if typeof b is "undefined"
  [
    "rgba("
    [
      r or 0
      g or 0
      b or 0
      a or 1
    ].join(",")
    ")"
  ].join ""

Utils.hex2rgb = (hex) ->
  bigint = parseInt(hex, 16)
  unless isNaN(bigint)
    r = (bigint >> 16) & 255
    g = (bigint >> 8) & 255
    b = bigint & 255
    r: r
    g: g
    b: b
  else
    if hex is "red"
      r: 255
      g: 0
      b: 0
    else if hex is "green"
      r: 0
      g: 255
      b: 0
    else if hex is "blue"
      r: 0
      g: 0
      b: 255

Utils.rgb2hex = (rgb) ->
  rgb = rgb.match(/^rgb\((\d+),\s*(\d+),\s*(\d+)\)$/)
  "#" + ("0" + parseInt(rgb[1], 10).toString(16)).slice(-2) + ("0" + parseInt(rgb[2], 10).toString(16)).slice(-2) + ("0" + parseInt(rgb[3], 10).toString(16)).slice(-2)

module.exports = Utils
