Utils = require "../utils/color"
EventHandler = require "biojs-events"

# this is an example of how one could color the MSA
# feel free to create your own color scheme
class Colorator

  scheme: "taylor"

  constructor: (@msa) ->
    # register listeners
    console.log @msa

    @.on "residue:color", (data) =>
      #data.target.className = "biojs_msa_single_residue"
      residue = @getResidue data
      data.target.className += " biojs-msa-aa-" + residue

    @msa.on "residue:click", (data) =>
      data.target.className = "biojs_msa_single_residue"
      residue = @getResidue data
      data.target.className += " biojs-msa-aa-" + residue + "-selected"
      data.target.className += " shadowed"

    @msa.on "residue:mouseover", (data) ->
      @colorSelectedResidue data.div,data.tSeq, data.pos

    @.on "row:color", (data) =>
      rowGroup = data.target
      rowGroup.className = "biojs_msa_seqblock"
      rowGroup.className += " biojs-msa-schemes-" + @scheme

    # TODO: fix me
    @msa.on "row:select", (data) =>
      rowGroup = data.target
      rowGroup.className = "biojs_msa_seqblock"
      rowGroup.className += " biojs-msa-schemes-" + @scheme

    @.on "column:color", (data) =>
      columnGroup = data.target
      columnGroup.style.backgroundColor = "transparent"
      columnGroup.style.color = ""

    @msa.on "column:select", (data) =>
      columnGroup = data.target
      columnGroup.style.backgroundColor =
      Utils.rgba(Utils.hex2rgb("ff0000"),1.0)
      columnGroup.style.color = "white"

    @.on "label:color", (data) =>
      labelGroup = data.target
      if not labelGroup.color?
        color = {}
        color.r = Math.ceil(Math.random() * 255)
        color.g = Math.ceil(Math.random() * 255)
        color.b = Math.ceil(Math.random() * 255)
        labelGroup.color = color
      labelGroup.color = Utils.hex2rgb "ffffff"
      labelGroup.style.backgroundColor = Utils.rgba(labelGroup.color, 0.5)

    @msa.on "label:select", (data) =>
      labelGroup = data.target
      rect = labelGroup.children[0]
      label = labelGroup.children[1]
      labelGroup.style.textColor = "white"
      labelGroup.color = Utils.hex2rgb "ff0000"
      labelGroup.style.backgroundColor = Utils.rgba(labelGroup.color, 1.0)

  setScheme: (name) ->
    @scheme = name
    @scheme = name.toLowerCase()

  getResidue: (data) ->
    seq = @msa.seqs[data.seqId].seq
    residue = seq.charAt(data.rowPos)
    if residue is "-"
      "Gap"
    else
      residue

# merge this class with the event class
EventHandler.mixin Colorator.prototype

module.exports = Colorator
