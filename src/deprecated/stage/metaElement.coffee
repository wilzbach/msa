StageElement = require "./stageElement"

module.exports =
  class MetaElement extends StageElement

    constructor: (@msa) ->

    # calculates the width of this container
    width: (n) ->
      return @msa.zoomer.columnWidth

    create: (row) ->
      spanGlobal = document.createElement("span")
      spanGlobal.innerHTML = "meta stuff"
      console.log "meta"
      return spanGlobal
