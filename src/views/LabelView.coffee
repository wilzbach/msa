view = require("./view")

LabelView = view.extend

  initialize: (data) ->
    @seq = data.seq
    @g = data.g
    @el.setAttribute "class", "biojs_msa_labels"

  events: {
    "click": "open",
    "mouseover": "open",
    "mouseout": "open",
  }

  render: ->
    #@renderSubviews()
    @el.style.width = "#{@g.zoomer.seqOffset}px"
    @el.style.height = "#{@g.zoomer.columnHeight}px"
    @el.style.fontSize = "#{@g.zoomer.labelFontsize}px"

    if @g.zoomer.isTextVisible()
      @el.textContent = @seq.name
    else
      @el.textContent = ""
    @el.textContent = @seq.name

    @

  open: ->
    console.log "#{@seq.id} clicked"
      #@msa.selmanager.handleSel new selection.HorizontalSelection(@msa, id), evt

module.exports = LabelView
