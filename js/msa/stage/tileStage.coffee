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

      console.log "#tiles x:" + @tilesX + ",y:" + @tilesY

      @canvas.addEventListener "mousemove", (e) =>
        if @dragStartX? and @draglock?
          distX= e.pageX - @dragStartX
          distY = e.pageY - @dragStartY

          @viewportX = @dragViewStartX - distX
          @viewportY = @dragViewStartY - distY
          @draw()

          # do not allow out of bounds
          @viewportX = 0 if @viewportX < 0
          @viewportY = 0 if @viewportY < 0

          height = @msa.zoomer.columnHeight
          width = @msa.zoomer.columnWidth



          @viewportX = @maxWidth - @canvas.width if @maxWidth - @canvas.width < @viewportX
          @viewportY = @maxHeight if @maxHeight < @viewportY

          console.log "#tiles x:" + distX + ",y:" + distY
          @pauseEvent e

      @canvas.addEventListener "dblclick", (e) =>
        @msa.zoomer.columnWidth += 1
        @msa.zoomer.columnHeight += 1
        @refreshZoom()

      @canvas.addEventListener "mousedown", (e) =>
        @pauseEvent e
        @dragStartX = e.pageX
        @dragStartY = e.pageY
        @dragViewStartX = @viewportX
        @dragViewStartY = @viewportY
        @draglock = true

      @canvas.addEventListener "mouseup", (e) =>
        @draglock = undefined

      @canvas.addEventListener "mouseout", (e) =>
        @draglock = undefined

      @map = []


      @viewportX = 100
      @viewportY = 100

      #@animate()
      @timestamp = 0


    pauseEvent: (e) ->
      e=e || window.event
      if e.stopPropagation
        e.stopPropagation()
      if e.preventDefault
        e.preventDefault()
      e.cancelBubble=true
      e.returnValue=false
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
      console.log "maxWidth:" + @maxWidth + "maxHeight:" + @maxHeight
      @msa.log.log "zoom:" + width

    draw: ->

      #@msa.zoomer.setZoomLevel 1
      distViewToFirstX = @viewportX % @tileSize
      distViewToFirstY = @viewportY % @tileSize

      console.log distViewToFirstX

      firstXTile = Math.ceil(@viewportX / @tileSize)
      firstYTile = Math.ceil(@viewportY / @tileSize)

      exactFit = -1
      exactFit = 0 if distViewToFirstX is 0

      unless @orderList?
        @orderList = @msa.ordering.getSeqOrder @msa.seqs
        @maxLength = @msa.zoomer.getMaxLength()
        #@animate()
        @msa.zoomer.columnWidth = 1
        @msa.zoomer.columnHeight = 1
        @refreshZoom()

      for i in [exactFit..@tilesX - 1 - exactFit] by 1
        for j in [exactFit..@tilesY - 1 - exactFit] by 1

          mapX = i + firstXTile
          mapY = j + firstYTile

          tileX = i * @tileSize - distViewToFirstX
          tileY = j * @tileSize - distViewToFirstY

          height = @msa.zoomer.columnHeight

          if @map[height]?[mapX]?[mapY]?
            tile = @map[height][mapX][mapY]
          else
            tile = @drawTile mapX,mapY

          #@ctx.fillStyle = "red"
          #@ctx.fillRect i * @tileSize, j * @tileSize,@tileSize,@tileSize
          #@ctx.fillRect tileX,tileY,@tileSize,@tileSize
          #@ctx.putImageData tile,0,0,tileX,tileY,@tileSize,@tileSize

          #console.log "tile i:" + i + ",j:" + j
          #console.log "tile i:" + tileX + ",j:" + tileY
          @ctx.putImageData tile,tileX,tileY
          #@ctx.drawImage tile,tileX,tileY

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

        seqStartX = Math.floor(tileX / width )
        seqEndX = seqStartX + Math.ceil(@tileSize  / width )

        seqStartY = Math.floor(tileY / height)
        seqEndY = seqStartY + Math.ceil(@tileSize  / height)

        cx.fillStyle = "#eeeeee"
        cx.fillRect 0,0,@tileSize,@tileSize

        #console.log seqStartX
        #console.log seqEndX

        pos = 0
        for seqId in [seqStartY..seqEndY- 1] by 1
          seq = @msa.seqs[@orderList[seqId]].tSeq.seq
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

      tile = cx.getImageData 0,0,@tileSize,@tileSize
      @map[height][i][j] = tile
      cx.clearRect(0, 0, @canvasTile.width, @canvasTile.height);
      return tile

    getRandomColor: ->
      letters = '0123456789ABCDEF'.split('')
      color = '#'
      for i in [0..5] by 1
          color += letters[Math.floor(Math.random() * 16)]
      color

    _createCanvas: ->
      @canvas = document.createElement "canvas"
      @canvas.width = 500
      @canvas.height = 500
      @ctx = @canvas.getContext "2d"
      @canvas.setAttribute "id","#{@globalID}_canvas"

      @canvasWrapper = document.createElement "div"
      @canvasWrapper.appendChild @canvas
      @canvasWrapper.style.overflow = "scroll"
      @canvasWrapper.style.height = "550px"

      @canvasTile = document.createElement "canvas"
      @canvasTile.width = @tileSize
      @canvasTile.height = @tileSize
      @ctxTile = @canvasTile.getContext "2d"
