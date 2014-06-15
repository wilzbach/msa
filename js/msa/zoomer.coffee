define [], ->
  class Zoomer

    constructor: ->

      @columnWidth = 20
      @columnHeight = 20
      @columnSpacing = 5

      # how much space for the labels?
      @seqOffset = 140
      @labelFontsize = 13

    addZoombar: ->
      return
      zoomForm = document.createElement("form")
      zoomSlider = document.createElement("input")
      zoomSlider.type = "range"
      zoomSlider.name = "points"
      zoomSlider.min = 1
      zoomSlider.max = 15
      zoomForm.appendChild zoomSlider
      @zoomSlider = zoomSlider
      zoomSlider.addEventListener "change", (evt) =>
        console.log @zoomSlider.value
        value = @zoomSlider.value
        @columnWidth = 2 * value
        @labelFontsize = 3 + 2 * value
        @columnHeight = 5 + 3 * value
        @columnSpacing = 0
        @seqOffset = 50 + 20 * value
        @redrawEntire()

      @container.appendChild zoomForm
