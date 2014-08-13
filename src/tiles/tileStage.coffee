Utils = require "../utils/general"
TileEventHandler = require "./tileEventHandler"
TileStageButtons = require "./tileStageButtons"
TileStageSequence = require "./tileStageSequence"
AsyncLoader = require "./asyncLoader"
stage = require "../stage/stage"

module.exports =

  class TileStage extends stage

    # builds the tile stage
    # @param [MSA] msa the MSA instance
    constructor: (@msa) ->
      @msa.zoomer.setZoomLevel 1
      @tileSize = 200

      @evtHdlr = new TileEventHandler this
      @control = new TileStageButtons this
      @seqtile = new TileStageSequence this
      @loader = new AsyncLoader this

      @_createCanvas()
      @_prepareCanvas()

      # default, start values
      @viewportX = 0
      @viewportY = 0
      @dblClickVx = 2
      @dblClickVy = 2

      @debug = 1

    # moves the center of the canvas to relative x,y
    #
    # @param [int] x xCoord of the new center
    # @param [int] y yCoord of the new center
    moveCenterTo: (mouseX,mouseY) ->
      @moveView Math.round( (mouseX) - (@canvas.width / 2) ) , Math.round( (mouseY) - (@canvas.height / 2) )

    # moves the viewport for the value of (x,y)
    #
    # @param [int] x relative viewport move on x-axis
    # @param [int] y relative viewport move on y-axis
    moveView: (x,y) ->
      @viewportX += x
      @viewportY += y

    # this rescales the center for vx and vy
    # 1 means no zooming
    # 2 means zooming with factor 2
    # 0.5 zooming out with factor 2
    #
    # @param [int] vx xVelocity
    # @param [int] vy yVelocity
    zoomCanvas: (vx, vy) ->

      newVx = @msa.zoomer.columnWidth * vx
      newVy = @msa.zoomer.columnHeight * vy

      if newVx < 1 or newVy < 1
        @msa.log "invalid zoom level - x:" + newVx + "y:" + newVy
      else
        #@msa.log "#BEFORE viewix:" + @viewportX + ",y:" + @viewportY

        if vx isnt 0
          centerX = @viewportX + @canvas.width / 2
          centerX = centerX / @msa.zoomer.columnWidth * (newVx)
          @viewportX = Math.round(centerX - @canvas.width / 2)
        if vy isnt 0
          centerY = @viewportY + @canvas.height / 2
          centerY = centerY / @msa.zoomer.columnHeight * (newVy)
          @viewportY = Math.round(centerY - @canvas.height / 2)

        #@msa.log "#AFTER viewix:" + @viewportX + ",y:" + @viewportY

        @msa.zoomer.columnWidth = newVx
        @msa.zoomer.columnHeight = newVy

        @refreshZoom()

      # needs to be done in all cases - moveCenter doesnt check
      @checkPos()

    # checks whether the viewport is out of bounds
    checkPos: ->
      [@viewportX,@viewportY] = @_checkPos @viewportX,@viewportY

    # checks whether the viewport is out of bounds
    _checkPos: (x,y) ->
      # do not allow out of bounds
      x = 0 if x < 0
      y = 0 if y < 0

      x = @maxWidth - @canvas.width if @maxWidth - @canvas.width < x
      y = @maxHeight if @maxHeight < y

      [x,y]


    # draws all the tiles
    draw: ->

      unless @orderList?
        @orderList = @msa.ordering.getSeqOrder @msa.seqs
        @maxLength = @msa.zoomer.getMaxLength()
        #@animate()
        @msa.zoomer.columnWidth = @msa.zoomer.columnWidth
        @msa.zoomer.columnHeight = @msa.zoomer.columnHeight
        @refreshZoom()

        # render the whole alignment in the background
        if @msa.config.prerender
          @loader.asyncLoader 1,0,0,0,1
          @loader.asyncLoader 1,1,0,0,1
          @loader.asyncLoader 1,2,0,0,1
          @loader.asyncLoader 1,3,0,0,1

      height = @msa.zoomer.columnHeight
      [distViewToFirstX,distViewToFirstY,firstXTile,firstYTile] = @getFirstTile()

      #@msa.log "tileX" + firstXTile + ",tileY:" + firstYTile

      # remove extra tiles on exact fit
      notExactFitX = if distViewToFirstX is 0 then 0 else 2
      notExactFitY = if distViewToFirstY is 0 then 0 else 2

      @ctx.clearRect 0, 0, @canvas.width, @canvas.height

      for i in [0..@tilesX - 1 + notExactFitX] by 1
        for j in [0..@tilesY - 1 + notExactFitY] by 1

          mapX = i + firstXTile
          mapY = j + firstYTile

          tileX = i * @tileSize - distViewToFirstX
          tileY = j * @tileSize - distViewToFirstY

          if @map[height]?[mapX]?[mapY]?
            tile = @map[height][mapX][mapY]
          else
            # put the cached sequence on stage
            tile = @seqtile.drawTile mapX,mapY

          #@msa.log "tile i:" + mapX + ",j:" + mapY
          #@msa.log "tile i:" + tileX + ",j:" + tileY
          @ctx.putImageData tile,tileX,tileY
          #@ctx.drawImage tile,tileX,tileY # (slower)

      # control overlays
      @control.draw @ctx

      return @canvasWrapper

    # returns the first visible tile
    getFirstTile: ->
      distViewToFirstX = @viewportX % @tileSize
      distViewToFirstY = @viewportY % @tileSize

      # hack for negative tiles
      distViewToFirstX += @tileSize if distViewToFirstX < 0
      distViewToFirstY += @tileSize if distViewToFirstY < 0

      firstXTile = Math.floor(@viewportX / @tileSize)
      firstYTile = Math.floor(@viewportY / @tileSize)

      #@msa.log "#viewDrawx:" + @viewportX + ",y:" + @viewportY
      #@msa.log "firstY:" + firstYTile
      #@msa.log "first to first x"  + distViewToFirstX

      return [distViewToFirstX,distViewToFirstY,firstXTile,firstYTile]

    refreshZoom: ->
      @tilesX = Math.ceil(@canvas.width / @tileSize)
      @tilesY = Math.ceil(@canvas.height / @tileSize)

      height = @msa.zoomer.columnHeight
      width = @msa.zoomer.columnWidth
      @maxWidth = @maxLength * width
      @maxHeight = @msa.seqs.length * height

      #@msa.log @msa.zoomer.columnWidth
      #@msa.log @msa.zoomer.columnHeight
      #@msa.log "maxWidth:" + @maxWidth + ",maxHeight:" + @maxHeight
      #@msa.log "zoom:" + width

    # get the width of the component
    width: (n) ->
      return n * @msa.zoomer.columnWidth

    # TODO: not used??
    resetTiles: ->
      @map = []

    # init zoom + event handler
    _prepareCanvas: ->
      @refreshZoom()
      @viewportX = 0
      @viewportY = 0

      # empty, default values
      @map = []

      @evtHdlr.init()

    # init the canvas
    _createCanvas: ->
      @canvas = document.createElement "canvas"
      @canvas.width = @msa.container.offsetWidth
      @canvas.height = @msa.container.parentNode.offsetHeight
      @canvas.id = "can"
      @ctx = @canvas.getContext "2d"
      @canvas.setAttribute "id","#{@globalID}_canvas"
      @canvas.style.cursor  = "move"

      @canvasWrapper = document.createElement "div"
      @canvasWrapper.appendChild @canvas
      #@canvasWrapper.style.overflow = "scroll"
      #@canvasWrapper.style.height = "550px"

      @canvasTile = document.createElement "canvas"
      @canvasTile.width = @tileSize
      @canvasTile.height = @tileSize
      @ctxTile = @canvasTile.getContext "2d"
