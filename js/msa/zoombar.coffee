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

      zoomSlider.addEventListener "change", (evt) =>
        console.log @zoomSlider.value
        value = @zoomSlider.value
        @msa.zoomer.setZoomLevel(value)
        @msa.config.autofit = false
        @msa.redrawContainer()

      # save for the future
      @zoomSlider = zoomSlider

    draw: ->
      @zoomSlider
