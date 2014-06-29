define [], ->

  class TileEventHandler

    constructor: (@tiler) ->

    _onMouseMove: (e) ->
      if @dragStartX? and @draglock?
        @moveCanvasDragEvent e

    _onMouseUp: (e) ->
      if @dragStartX? and @draglock?
        @moveCanvasDragEvent e

      @draglock = undefined

    _onMouseOut: (e) ->
      @draglock = undefined

    _onMouseDown: (e) =>
      [mouseX,mouseY]= @getMouseCoords e

      unless @tiler.control.checkForEvents mouseX,mouseY
        @pauseEvent e
        @dragStartX = e.pageX
        @dragStartY = e.pageY
        @dragViewStartX = @tiler.viewportX
        @dragViewStartY = @tiler.viewportY
        @draglock = true

    _onContextMenu: (e) =>
      #TODO: only on dblclick
      @tiler.zoomCanvas 1 / @tiler.dblClickVx, 1 / @tiler.dblClickVy
      @tiler.refreshZoom()
      @tiler.draw()

    # TODO: move to utils
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

    _onDblClick: (e) ->
      #if not @rect? or @rect?.left is 0
      #  @rect = @canvas.getBoundingClientRect()
      @draglock = undefined

      [mouseX,mouseY]= @getMouseCoords e

      @tiler.moveCenter mouseX,mouseY
      @tiler.zoomCanvas @tiler.dblClickVx,@tiler.dblClickVy
      @tiler.draw()

      #console.log "#mouse:" + mouseX + ",y:" + mouseY
      #console.log "#viewix:" + @viewportX + ",y:" + @viewportY

    moveCanvasDragEvent: (e) ->
      distX = e.pageX - @dragStartX
      distY = e.pageY - @dragStartY

      @tiler.viewportX = @dragViewStartX - distX
      @tiler.viewportY = @dragViewStartY - distY

      @tiler.checkPos()
      @tiler.draw()
      @pauseEvent e

    # TODO: move to utils
    pauseEvent: (e) ->
      e= window.event if not e?
      if e.stopPropagation
        e.stopPropagation()
      if e.preventDefault
        e.preventDefault()
      e.cancelBubble = true
      e.returnValue = false
      return false


