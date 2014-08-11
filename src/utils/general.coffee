Utils = {}

###
Remove an element and provide a function that inserts it into its original position
https://developers.google.com/speed/articles/javascript-dom
@param element {Element} The element to be temporarily removed
@return {Function} A function that inserts the element into its original position
###
Utils.removeToInsertLater = (element) ->
  parentNode = element.parentNode
  nextSibling = element.nextSibling
  parentNode.removeChild element
  ->
    if nextSibling
      parentNode.insertBefore element, nextSibling
    else
      parentNode.appendChild element
    return


###
fastest possible way to destroy all sub nodes (aka childs)
http://jsperf.com/innerhtml-vs-removechild/15
@param element {Element} The element for which all childs should be removed
###
Utils.removeAllChilds = (element) ->
  count = 0
  while element.firstChild
    count++
    element.removeChild element.firstChild
  return


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

Utils.splitNChars = (txt, num) ->
  result = []
  i = 0

  while i < txt.length
    result.push txt.substr(i, num)
    i += num
  result


# count a associative array
Object.size = (obj) ->
  size = 0
  key = undefined
  for key of obj
    size++  if obj.hasOwnProperty(key)
  size

module.exports = Utils
