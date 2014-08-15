view = require("./view")

HeaderView = view.extend

  className: "biojs_msa_marker"

  initialize: (data) ->
    @seq = data.seq
    @g = data.g

  events: {
    "click": "open",
  }

  render: ->
    #@renderSubviews()
    n = 0

    nMax = @g.zoomer.len
    if nMax is 0
      nMax = @g.zoomer.getMaxLength()

    nMax = 100
    stepSize = 1

    while n < nMax
      span = document.createElement "span"
      #opts.createElement { target: residueSpan, rowPos: n}
      span.style.width = @g.zoomer.columnWidth * stepSize + "px"
      span.style.display = "inline-block"
      span.textContent = "x"
      span.rowPos = n
      span.stepPos = n / stepSize

      @el.appendChild span
      n +=stepSize
    @

  open: (evt) ->
    console.log "header clicked"
    #@msa.selmanager.handleSel new selection.VerticalSelection(@msa,
    #  evt.target.rowPos, evt.target.stepPos), evt

module.exports = HeaderView
