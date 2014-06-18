define [], ->
  class ZoomBar

    constructor: (@msa) ->
      zoomForm = document.createElement("form")
      zoomSlider = document.createElement("input")
      zoomSlider.type = "range"
      zoomSlider.name = "points"
      zoomSlider.min = 1
      zoomSlider.max = 30
      zoomForm.appendChild zoomSlider
      @locked = false

      #zoomSlider.addEventListener "change", (evt) =>
      #  @_reDraw()

      zoomSlider.addEventListener "mousemove", ((evt) =>
        if @lastValue isnt @zoomSlider.value
          @lastValue = @zoomSlider.value
          @_reDraw()
        true
      ), false

      # save for the future
      @zoomSlider = zoomSlider

    _reDraw: ->
      unless @locked
        @locked = true
        console.log @zoomSlider.value
        value = @zoomSlider.value
        @msa.zoomer.setZoomLevel(value)
        @msa.config.autofit = false
        @msa.seqmgr.recolorStage()
        #@msa.redraw('stage')
        @msa.redraw('marker')
        @locked = false

    draw: ->
      @zoomSlider
