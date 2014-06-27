define ["msa/utils", "msa/stage/main", "cs!msa/stage/canvasStage"], (Utils,stage,CanvasStage) ->

  class TileStage extends stage.stage

    constructor: (@msa) ->
      @msa.zoomer.setZoomLevel 1
      @viewportX = 0
      @viewportY = 0
      @tileSize = 200
      @_createCanvas()
      @tilesX = Math.ceil(@canvas.width / @tileSize)
      @tilesY = Math.ceil(@canvas.height / @tileSize)

      #console.log "#tiles x:" + @tilesX + ",y:" + @tilesY

      @canvas.addEventListener "mousemove", (e) =>
        @_onMouseMove e

      @canvas.addEventListener "dblclick", (e) =>
        @_onDblClick e

      @canvas.addEventListener "contextmenu", (e) =>
        @_onContextMenu e

      @canvas.addEventListener "mousedown", (e) =>
        @_onMouseDown e

      @canvas.addEventListener "mouseup", (e) =>
        @_onMouseUp e

      @canvas.addEventListener "mouseout", (e) =>
        @_onMouseOut e

      @events = {}

      @map = []

      @viewportX = 120
      @viewportY = 100
      @dblClickVx = 2
      @dblClickVy = 2

      #@animate()
      @timestamp = 0

    _onMouseMove: (e) ->
      if @dragStartX? and @draglock?
        @moveCanvasDragEvent e

    _onMouseUp: (e) ->
      if @dragStartX? and @draglock?
        @moveCanvasDragEvent e

      @draglock = undefined

    _onMouseOut: (e) ->
      @draglock = undefined

    _onMouseDown: (e) ->
      [mouseX,mouseY]= @getMouseCoords e

      unless @checkForEvents mouseX,mouseY
        @pauseEvent e
        @dragStartX = e.pageX
        @dragStartY = e.pageY
        @dragViewStartX = @viewportX
        @dragViewStartY = @viewportY
        @draglock = true

    _onContextMenu: (e) ->
      #TODO: only on dblclick
      @zoomCanvas 1 / @dblClickVx, 1 / @dblClickVy
      @draw()

    # TODO: move to utils
    getMouseCoords: (e) ->
      # center the view on double click
      mouseX = e.offsetX
      mouseY = e.offsetY

      unless e.offsetX?
        mouseX = e.layerX
        mouseY = e.layerY

      unless mouseX?
        console.log e
        console.log "no mouse event defined. your browser sucks"
        return

      # TODO: else
      return [mouseX,mouseX]

    _onDblClick: (e) ->
      #if not @rect? or @rect?.left is 0
      #  @rect = @canvas.getBoundingClientRect()
      @draglock = undefined

      [mouseX,mouseY]= @getMouseCoords e

      @moveCenter mouseX,mouseY
      @zoomCanvas @dblClickVx,@dblClickVy
      @draw()

      #console.log "#mouse:" + mouseX + ",y:" + mouseY
      #console.log "#viewix:" + @viewportX + ",y:" + @viewportY

    moveCanvasDragEvent: (e) ->
      distX = e.pageX - @dragStartX
      distY = e.pageY - @dragStartY

      @viewportX = @dragViewStartX - distX
      @viewportY = @dragViewStartY - distY

      @checkPos()
      @draw()
      @pauseEvent e

    # moves the center of the canvas to relative x,y
    moveCenter: (mouseX,mouseY) ->

      @viewportX = Math.round( @viewportX + (mouseX) - (@canvas.width / 2) )
      @viewportY = Math.round( @viewportY + (mouseY) - (@canvas.height / 2) )

      #TODO: do we need to check here -> redundant with zoomer
      @checkPos()

    # this rescales the center for vx and vy
    zoomCanvas: (vx, vy) ->

      newVx = @msa.zoomer.columnWidth * vx
      newVy = @msa.zoomer.columnHeight * vy

      if newVx < 1 or newVy < 1
        console.log "invalid zoom level - x:" + newVx + "y:" + newVy
      else
        if vx isnt 0
          @viewportX = Math.round(@viewportX / @msa.zoomer.columnWidth * (newVy))
        if vy isnt 0
          @viewportY = Math.round(@viewportY / @msa.zoomer.columnHeight * (newVx))

        @msa.zoomer.columnWidth += vx
        @msa.zoomer.columnHeight += vy

        @refreshZoom()

        #TODO: do we need to check here -> redundant with zoomer
        @checkPos()

    # goes through all events all checks for callbacks
    checkForEvents: (mouseX, mouseY) ->
      for name,arr of @events

        if (arr[0] <= mouseX and mouseX <= arr[2]) and
        (arr[1] <= mouseY and mouseY <= arr[3])
          arr[4]()
      false

    checkPos: ->
      [@viewportX,@viewportY] = @_checkPos @viewportX,@viewportY

    _checkPos: (x,y) ->
      # do not allow out of bounds
      x = 0 if x < 0
      y = 0 if y < 0

      x = @maxWidth - @canvas.width if @maxWidth - @canvas.width < x
      y = @maxHeight if @maxHeight < y

      [x,y]

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

    width: (n) ->
      return 0

    animate: (timestamp) =>
      console.log "time:" + (timestamp - @timestamp)

      @timestamp = timestamp
      if @viewportX < 150 or not @vx?
        @vx = 1
      if @viewportX > 200
        @vx = -1

      if @msa.zoomer.columnWidth < 2
        @vH = 1

      if not @vH?
        @vH = 1
        @msa.zoomer.columnWidth = 1
        @msa.zoomer.columnHeight = 1

      if @msa.zoomer.columnWidth > 10
        @vH = -1

      @vx = 0
      #@vH = 0

      @msa.zoomer.columnWidth += @vH
      @msa.zoomer.columnHeight += @vH

      console.log "columnwidth: " + @msa.zoomer.columnWidth

      @viewportX += @vx
      @viewportY += @vx
      #window.requestAnimationFrame @animate
      window.setTimeout @animate, 200
      @draw()

    resetTiles: ->
      @map = []

    refreshZoom: ->
      height = @msa.zoomer.columnHeight
      width = @msa.zoomer.columnWidth
      @maxWidth = @maxLength * width
      @maxHeight= @msa.seqs.length * height
      console.log "maxWidth:" + @maxWidth + ",maxHeight:" + @maxHeight
      @msa.log.log "zoom:" + width

    getFirstTile: ->
      distViewToFirstX = @viewportX % @tileSize
      distViewToFirstY = @viewportY % @tileSize

      firstXTile = Math.floor(@viewportX / @tileSize)
      firstYTile = Math.floor(@viewportY / @tileSize)

      console.log "#viewDrawx:" + @viewportX + ",y:" + @viewportY
      console.log "firstX:" + firstXTile
      console.log "first to first x"  + distViewToFirstX

      return [distViewToFirstX,distViewToFirstY,firstXTile,firstYTile]

    draw: ->

      unless @orderList?
        @orderList = @msa.ordering.getSeqOrder @msa.seqs
        @maxLength = @msa.zoomer.getMaxLength()
        #@animate()
        @msa.zoomer.columnWidth = 1
        @msa.zoomer.columnHeight = 1
        @refreshZoom()

      [distViewToFirstX,distViewToFirstY,firstXTile,firstYTile] = @getFirstTile()

      notExactFit = if distViewToFirstX is 0 then 0 else 2

      #console.log "tileX" + firstXTile + ",tileY:" + firstYTile

      @ctx.clearRect 0, 0, @canvas.width, @canvas.height

      distViewToFirstX += @tileSize if distViewToFirstX < 0
      distViewToFirstY += @tileSize if distViewToFirstY < 0

      for i in [0..@tilesX - 1 + notExactFit] by 1
        for j in [0..@tilesY - 1 + notExactFit] by 1

          mapX = i + firstXTile
          mapY = j + firstYTile

          tileX = i * @tileSize - distViewToFirstX
          tileY = j * @tileSize - distViewToFirstY

          height = @msa.zoomer.columnHeight

          if @map[height]?[mapX]?[mapY]?
            tile = @map[height][mapX][mapY]
          else
            tile = @drawTile mapX,mapY

          #@ctx.fillRect tileX,tileY,@tileSize,@tileSize
          #@ctx.putImageData tile,0,0,tileX,tileY,@tileSize,@tileSize

          #console.log "tile i:" + mapX + ",j:" + mapY
          #console.log "tile i:" + tileX + ",j:" + tileY
          @ctx.putImageData tile,tileX,tileY
          #@ctx.drawImage tile,tileX,tileY

      # control overlays

      # zoom control
      @ctx.fillStyle = "red"
      @ctx.globalAlpha = 0.5;
      @ctx.fillRect @canvas.width - 40, @canvas.height - 35,15,15
      callback = -> alert "hi"
      @events.zoomIn = [@canvas.width - 40, @canvas.height - 35,@canvas.width -
      25,@canvas.height - 20,callback]
      @ctx.globalAlpha = 1

      @ctx.fillStyle = "blue"
      @ctx.fillRect @canvas.width - 40, @canvas.height - 20,15,15
      @events.zoomOut = [@canvas.width - 40, @canvas.height - 20,15,15,callback]

      return @canvasWrapper

    drawTile: (i,j) ->

      # draw
      height = @msa.zoomer.columnHeight
      width = @msa.zoomer.columnWidth

      @map[height] = [] unless @map[height]?
      @map[height][i] = [] unless @map[height][i]?

      #height = 1
      #width = 1
      tileX = i * @tileSize
      tileY = j * @tileSize

      cx = @ctxTile

      if @maxWidth > tileX and @maxHeight > tileY and tileX >= 0 and tileY >= 0

        # calc position of seqs
        seqStartX = Math.floor(tileX / width )
        seqEndX = seqStartX + Math.ceil(@tileSize  / width )

        seqStartY = Math.floor(tileY / height)
        seqEndY = seqStartY + Math.ceil(@tileSize  / height)

        # no overflow
        seqEndX = @maxLength if @maxLength > seqEndX
        seqEndY = @msa.seqs.length if seqEndY > @msa.seqs.length

        # background bg for end
        cx.fillStyle = "#eeeeee"
        cx.fillRect 0,0,@tileSize,@tileSize

        #console.log "endY:" + seqEndY
        #console.log "endX:" + seqEndX

        pos = 0
        for seqNr in [seqStartY..seqEndY- 1] by 1
          id = @orderList[seqNr]
          seq = @msa.seqs[id].tSeq.seq
          for index in [seqStartX..seqEndX - 1] by 1
            color = CanvasStage.taylorColors[seq[index]]
            if color is undefined
              color = "111111"
              continue
            cx.fillStyle = "#" + color
            cx.fillRect((index - seqStartX) * width,pos,width,height)

          pos += height

        #@ctxTile.fillStyle = "blue"
        #@ctxTile.fillRect 0,0,@tileSize,@tileSize
      else
        #@ctxTile.fillStyle = @getRandomColor()
        cx.fillStyle = "grey"
        cx.fillRect 0,0,@tileSize,@tileSize


      # debug drawing
      cx.rect 0,0,@tileSize,@tileSize
      cx.stroke()
      cx.font = "30px Georgia"
      cx.fillStyle = "#000000"
      cx.fillText "#{j},#{i}",20,50
      endPos = Math.floor @tileSize * 3 / 4
      cx.fillText "#{j},#{i}",20,endPos
      cx.fillText "#{j},#{i}",endPos,50
      cx.fillText "#{j},#{i}",endPos,endPos
      tile = cx.getImageData 0,0,@tileSize,@tileSize
      @map[height][i][j] = tile
      cx.clearRect(0, 0, @canvasTile.width, @canvasTile.height)
      return tile

    _createCanvas: ->
      @canvas = document.createElement "canvas"
      @canvas.width = 500
      @canvas.height = 500
      @canvas.id = "can"
      @ctx = @canvas.getContext "2d"
      @canvas.setAttribute "id","#{@globalID}_canvas"
      @canvas.style.cursor  = "move"

      @canvasWrapper = document.createElement "div"
      @canvasWrapper.appendChild @canvas
      @canvasWrapper.style.overflow = "scroll"
      @canvasWrapper.style.height = "550px"

      @canvasTile = document.createElement "canvas"
      @canvasTile.width = @tileSize
      @canvasTile.height = @tileSize
      @ctxTile = @canvasTile.getContext "2d"
