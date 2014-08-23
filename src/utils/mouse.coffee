module.exports = Mouse =

  # returns the mouse x & y coords
  getMouseCoords: (e) ->
    # center the view on double click
    mouseX = e.offsetX
    mouseY = e.offsetY

    unless mouseX?
      mouseX = e.layerX
      mouseY = e.layerY

    unless mouseX?
      mouseX = e.pageX
      mouseY = e.pageY

    unless mouseX?
      console.log e
      console.log "no mouse event defined. your browser sucks"
      return

    # TODO: else
    return [mouseX,mouseY]
