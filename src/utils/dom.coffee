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

module.exports = Utils
