define [], ->
  class ZoomBar

    constructor: (@msa) ->
      zoomForm = document.createElement("form")
      zoomSlider = document.createElement("input")
      zoomSlider.type = "range"
      zoomSlider.name = "points"
      zoomSlider.min = 1
      zoomSlider.max = 15
      zoomForm.appendChild zoomSlider
      @locked = false

      #zoomSlider.addEventListener "change", (evt) =>
      #  @_reDraw()

      zoomSlider.addEventListener "mousemove", (evt) =>
        if @lastValue isnt @zoomSlider.value
          @lastValue = @zoomSlider.value
          unless @locked
            @locked = true
            window.setTimeout @_reDraw,10
          else
            console.log "locked"

      # save for the future
      @zoomSlider = zoomSlider

    _reDraw: =>
      console.log @zoomSlider.value
      value = @zoomSlider.value
      @msa.zoomer.setZoomLevel(value * 2)
      @msa.config.autofit = false
      @msa.redraw('stage')
      @msa.redraw('marker')
      @locked = false

    draw: ->
      @zoomSlider
