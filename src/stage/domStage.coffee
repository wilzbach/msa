Utils = require "../utils/general"
stage = require "../stage/index"

module.exports =
  # manages all main MSA stage
  # manages the elements of every row and calls these plugins
  class DomStage

    constructor: (@msa) ->
      @elements = []
      @_createRowElements()

      # register events
      @msa.on "redraw", @redraw
      @msa.on "drawSeq", (seq) -> @drawSeq(seq)

    # pushes the different vis plugins onto the DOM
    _createRowElements: ->
      @elements = []
      if @msa.config.visibleElements.labels
        @elements.labels= new stage.labelElement @msa

      #if @msa.config.visibleElements.features
        @elements.meta = new stage.metaElement @msa

      if @msa.config.visibleElements.seqs
        @elements.seq = new stage.seqElement @msa

      #if @msa.config.visibleElements.features
        @elements.features =  new stage.featureElement @msa


    _createContainer: ->
      # TODO: remove old canvas
      @canvas = document.createElement "div"
      @canvas.setAttribute "id","#{@globalID}_canvas"
      @canvas.setAttribute "class", "biojs_msa_stage"

    reset: ->
      Utils.removeAllChilds @canvas
      @_createRowElements()

    # draws a row
    _drawRow: (row) ->
      layer = document.createElement "div"

      for el in @elements
        layer.appendChild el.create row

      layer.className = "biojs_msa_layer"
      row.layer = layer

    # loops over all RowPlugins and
    # draws all of them per row
    draw: ->
      # check whether we need to reload the stage
      if @canvas?.childNodes.length > 0
        @redrawStage()
      else
        @_createContainer()
        start = new Date().getTime()

        # draw all seqs
        for index,row of @msa.seqs
          @_drawRow row
        console.log "Stage draw time: #{(new Date().getTime() - start)} ms"

        orderList = @msa.ordering.calcSeqOrder @msa.seqs

        # consistency check
        if orderList.length != Object.size @msa.seqs
          throw "Length of the input array "+ orderList.length +
            " does not match with the real world " + Object.size @msa.seqs

        # order all rows
        frag = document.createDocumentFragment()
        for i in[0..orderList.length - 1] by 1
          id = orderList[i]
          @msa.seqs[id].layer.style.paddingTop = "#{@msa.zoomer.columnSpacing}px"
          frag.appendChild @msa.seqs[id].layer

        @canvas.appendChild frag
      return @canvas

    # recolors all subchilds stage
    redrawStage: =>
      @msa.selmanager.cleanup()

      textVisibilityChanged = false
      if @internalTextDisplay isnt @msa.zoomer.isTextVisible()
        textVisibilityChanged = true
        @internalTextDisplay = @msa.zoomer.isTextVisible()

      # all columns
      for key,curRow of @msa.seqs
        currentLayer = curRow.layer
        # TODO: redundant

        for i in [0..@elements.length - 1] by 1
          if currentLayer.childNodes[i]?
            @elements[i].redraw currentLayer.childNodes[i], curRow, textVisibilityChanged
          else
            console.log "a plugin wasn't loaded yet."

    # calculates the width of this element
    # ask each element recursively
    width: (n) ->
      width = 0
      if @elements?
        width += el.width n for el in @elements
      return width
