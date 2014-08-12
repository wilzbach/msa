StageElement = require "./StageElement"
FeatureStage = require("biojs-vis-easy_features").stage

module.exports =

class FeatureElement extends StageElement

  constructor: (@msa) ->

  width: (n) ->
    return 0

  redraw: (el,row,textVisibilityChanged) ->
    parentNode = row.layer

    foo = @create row
    parentNode.replaceChild foo,el

  create: (row) ->
    seqLen = row.tSeq.seq.length
    width = @msa.zoomer.columnWidth
    fontSize = @msa.zoomer.residueFontsize
    featureSpan = document.createElement "span"

    @stage = new FeatureStage()
    el = @stage.create featureSpan,row.tSeq.features,width,seqLen

    #event forwarding
    @stage.on "all", (eventName,feature) =>
      @msa.trigger "anno_" + eventName,feature

    return el
    offset =
      if @msa.config.visibleElements.labels
        labelOffset = document.createElement "span"
        labelOffset.style.width = "#{@msa.zoomer.seqOffset}px"
        rowSpan.appendChild labelOffset
