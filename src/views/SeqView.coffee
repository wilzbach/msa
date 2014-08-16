view = require("./view")

SeqView = view.extend

  initialize: (data) ->
    @g = data.g
    #@el.setAttribute "class", "biojs-msa-stage-level" + @g.zoomer.level
    @el.setAttribute "class", "biojs-msa-seqblock"
    @_build()

  events: {
    "click": "open",
  }

  _build: ->
    seq = @model.get("seq")
    for n in [0..seq.length - 1] by 1
      span = document.createElement "span"
      span.rowPos = n
      span.textContent = seq[n]
      @_drawResidue span, seq[n]
      # color it nicely
      #@g.colorscheme.trigger "residue:color", {target: span, seqId: @seq.id
      #  ,rowPos: n}
      @el.appendChild span

  render: ->
    #@renderSubviews()
    @el.className = "biojs_msa_seqblock"
    @el.className += " biojs-msa-schemes-" + @g.colorscheme.get "scheme"


    #@g.colorscheme.trigger "row:color", {target: @el, seqId: @seq.id}
    @

  open: (evt) ->
    console.log "opened", evt
    #@g.trigger "residue:click", {seqId:seqId, rowPos: rowPos, evt:evt,
      #target:evt.target}

  # sets the properties of a single residue
  _drawResidue: (span,residue) ->
    span.className = "biojs-msa-aa-" + residue

#    @msa.on "residue:click", (data) =>
#      data.target.className = "biojs_msa_single_residue"
#      residue = @getResidue data
#      data.target.className += " biojs-msa-aa-" + residue + "-selected"
#      data.target.className += " shadowed"
module.exports = SeqView
