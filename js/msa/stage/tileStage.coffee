define ["msa/utils", "msa/stage/main", "cs!msa/stage/tileEventHandler", "cs!msa/stage/tileStageButtons", "cs!msa/stage/tileStageSequence"], (Utils,stage, TileEventHandler, TileStageButtons, TileStageSequence) ->

  class TileStage extends stage.stage

    constructor: (@msa) ->
      @msa.zoomer.setZoomLevel 1
      @tileSize = 200

      @evtHdlr = new TileEventHandler this
      @control = new TileStageButtons this
      @seqtile = new TileStageSequence this

      @_createCanvas()
      @_prepareCanvas()

      # default, start values

      @viewportX = 120
      @viewportY = 100
      @dblClickVx = 2
      @dblClickVy = 2

      @debug = 1

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

    checkPos: ->
      [@viewportX,@viewportY] = @_checkPos @viewportX,@viewportY

    _checkPos: (x,y) ->
      # do not allow out of bounds
      x = 0 if x < 0
      y = 0 if y < 0

      x = @maxWidth - @canvas.width if @maxWidth - @canvas.width < x
      y = @maxHeight if @maxHeight < y

      [x,y]

    draw: ->

      unless @orderList?
        @orderList = @msa.ordering.getSeqOrder @msa.seqs
        @maxLength = @msa.zoomer.getMaxLength()
        #@animate()
        @msa.zoomer.columnWidth = 1
        @msa.zoomer.columnHeight = 1
        @refreshZoom()

      [distViewToFirstX,distViewToFirstY,firstXTile,firstYTile] = @getFirstTile()

      #console.log "tileX" + firstXTile + ",tileY:" + firstYTile

      # remove extra tiles on exact fit
      notExactFit = if distViewToFirstX is 0 then 0 else 2


      @ctx.clearRect 0, 0, @canvas.width, @canvas.height

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
            # put the cached sequence on stage
            tile = @seqtile.drawTile mapX,mapY

          #console.log "tile i:" + mapX + ",j:" + mapY
          #console.log "tile i:" + tileX + ",j:" + tileY
          @ctx.putImageData tile,tileX,tileY
          #@ctx.drawImage tile,tileX,tileY # (slower)

      # control overlays
      @control.draw @ctx

      return @canvasWrapper

    getFirstTile: ->
      distViewToFirstX = @viewportX % @tileSize
      distViewToFirstY = @viewportY % @tileSize

      # hack for negative tiles
      distViewToFirstX += @tileSize if distViewToFirstX < 0
      distViewToFirstY += @tileSize if distViewToFirstY < 0

      firstXTile = Math.floor(@viewportX / @tileSize)
      firstYTile = Math.floor(@viewportY / @tileSize)

      #console.log "#viewDrawx:" + @tiler.viewportX + ",y:" + @tiler.viewportY
      #console.log "firstX:" + firstXTile
      #console.log "first to first x"  + distViewToFirstX

      return [distViewToFirstX,distViewToFirstY,firstXTile,firstYTile]

    refreshZoom: ->
      @tilesX = Math.ceil(@canvas.width / @tileSize)
      @tilesY = Math.ceil(@canvas.height / @tileSize)

      height = @msa.zoomer.columnHeight
      width = @msa.zoomer.columnWidth
      @maxWidth = @maxLength * width
      @maxHeight= @msa.seqs.length * height
      #console.log "maxWidth:" + @maxWidth + ",maxHeight:" + @maxHeight
      @msa.log.log "zoom:" + width

    width: (n) ->
      return 0

    resetTiles: ->
      @map = []

    _prepareCanvas: ->
      @refreshZoom()
      @viewportX = 0
      @viewportY = 0

      # empty, default values
      @map = []

      # all events
      @canvas.addEventListener "mousemove", (e) =>
        @evtHdlr._onMouseMove e

      @canvas.addEventListener "dblclick", (e) =>
        @evtHdlr._onDblClick e

      @canvas.addEventListener "contextmenu", (e) =>
        @evtHdlr._onContextMenu e

      @canvas.addEventListener "mousedown", (e) =>
        @evtHdlr._onMouseDown e

      @canvas.addEventListener "mouseup", (e) =>
        @evtHdlr._onMouseUp e

      @canvas.addEventListener "mouseout", (e) =>
        @evtHdlr._onMouseOut e

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
