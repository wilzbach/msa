view = require("./view")

SeqView = view.extend

  initialize: (data) ->
    @seq = data.seq
    @g = data.g
    @el.setAttribute "class", "biojs-msa-stage-level" + @g.zoomer.level

  events: {
    "click": "open",
  }

  render: ->
    #@renderSubviews()
    for n in [0..@seq.seq.length - 1] by 1
      span = document.createElement "span"
      span.rowPos = n
      span.innerHTML = @seq.seq[n]
      # color it nicely
      #@g.colorscheme.trigger "residue:color", {target: span, seqId: @seq.id
      #  ,rowPos: n}
      @el.appendChild span
    @

  open: (evt) ->
    console.log "opened", evt
    #@g.trigger "residue:click", {seqId:seqId, rowPos: rowPos, evt:evt,
      #target:evt.target}

module.exports = SeqView
