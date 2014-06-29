define [], ->

  class TileStageButtons

    constructor: (@tiler) ->
      @events = {}

    # is called on every draw, keep overhead at a minimum
    draw: (ctx) ->
      @drawZooming ctx
      @drawProgressButton ctx
      @drawFullscreenButton ctx

    # goes through all events all checks for callbacks
    checkForEvents: (mouseX, mouseY) ->
      for name,arr of @events

        if (arr[0] <= mouseX and mouseX <= arr[2]) and
        (arr[1] <= mouseY and mouseY <= arr[3])
          arr[4]()
      false

    drawZooming: (ctx) ->
      # zoom control
      ctx.globalAlpha = 0.5

      # first
      ctx.fillStyle = "red"
      ctx.fillRect @tiler.canvas.width - 40, @tiler.canvas.height - 40,15,15
      callback = -> alert "hi"
      @events.zoomIn = [@tiler.canvas.width - 40, @tiler.canvas.height - 40,@tiler.canvas.width -
      25,@tiler.canvas.height - 20,callback]

      # second
      ctx.fillStyle = "blue"
      ctx.fillRect @tiler.canvas.width - 40, @tiler.canvas.height - 25,15,15
      @events.zoomOut = [@tiler.canvas.width - 40, @tiler.canvas.height - 25,15,15,callback]

      ctx.globalAlpha = 1

    drawProgressButton: (ctx) ->
      # current progress box
      ctx.fillStyle = "grey"
      ctx.globalAlpha = 0.7
      ratio = @tiler.maxHeight / @tiler.maxWidth
      progressWidth = 20
      progressHeight = 30
      ctx.fillRect @tiler.canvas.width - progressWidth - 50, @tiler.canvas.height - 40,progressWidth,progressHeight

      # current progress position
      pos = Math.round(@tiler.viewportY / @tiler.maxHeight * progressHeight)
      ctx.fillStyle = "red"
      ctx.fillRect @tiler.canvas.width - progressWidth - 50, @tiler.canvas.height - 40 + pos,progressWidth,1

      ctx.globalAlpha = 1

    drawFullscreenButton: (ctx) ->
      ctx.fillStyle = "red"
      ctx.globalAlpha = 0.5
      ctx.fillRect @tiler.canvas.width - 90, @tiler.canvas.height - 40,15,15
      @events.zoomIn = [@tiler.canvas.width - 90, @tiler.canvas.height - 40,@tiler.canvas.width -
      25,@tiler.canvas.height - 20, @goFullscreen]
      ctx.globalAlpha = 1

    goFullscreen: ->
      @tiler.canvas.width = window.innerWidth
      @tiler.canvas.height = window.innerHeight
      @tiler.canvas.style.position = "absolute"
      @tiler.canvas.style.left ="0px"
      @tiler.canvas.style.top = "0px"
      @tiler.canvasWrapper.style.overflow = "hidden"
      document.body.style.overflow = "hidden"
      document.body.height = "200px"
      window.scrollTo 0,0
      @tiler.refreshZoom()
      @tiler.draw()
