define ["msa/utils", "msa/row", "./main"], (Utils, Row,stage) ->

  class Stage

    constructor: (@msa) ->
      # unique stage id
      @ID =  String.fromCharCode(65 + Math.floor(Math.random() * 26))
      @globalID = 'biojs_msa_' + @ID

      @elements = []
      if @msa.config.visibleElements.labels
        @elements.push new stage.labelElement @msa

      if @msa.config.visibleElements.seqs
        @elements.push new stage.seqElement @msa

    _createContainer: ->
      # TODO: remove old canvas
      @canvas = document.createElement "div"
      @canvas.setAttribute "id","#{@globalID}_canvas"
      @canvas.setAttribute "class", "biojs_msa_stage"

    width: (n) ->
      width = 0
      width += el.width n for el in @elements
      return width

    reset: ->
      Utils.removeAllChilds @canvas

    addSeqs: (tSeqs) ->
      @msa.zoomer.autofit tSeqs if @msa.config.autofit
      # check whether array or single seq
      unless tSeqs.id?
        @addSeq e for e in tSeqs
      else
        @addSeq tSeqs

    addSeq: (tSeq) ->
      @msa.seqs[tSeq.id] = new Row tSeq, undefined

    removeSeq: (id) ->
      @msa.seqs[id].layer.destroy()
      delete seqs[id]
      # reorder
      @orderSeqsAfterScheme()
      # TODO: maybe redraw ?

    drawSeqs: ->
      for key,value of @msa.seqs
        @drawSeq value

    drawSeq: (row) ->
      layer = document.createElement "div"

      for el in @elements
        layer.appendChild el.create row.tSeq

      layer.className = "biojs_msa_layer"
      layer.style.height = "#{@msa.zoomer.columnHeight}px"

      row.layer = layer

    draw: ->
      # check whether we need to reload the stage
      if @canvas?
        @recolorStage()
      else
        @_createContainer()
        @drawSeqs()

        orderList = @msa.ordering.getSeqOrder @msa.seqs

        unless orderList?
          console.log "empty seq stage"
          return

        # consistency check
        if orderList.length != Object.size @msa.seqs
          console.log "Length of the input array "+ orderList.length +
            " does not match with the real world " + Object.size @msa.seqs
          return

        # prepare stage
        frag = document.createDocumentFragment()
        for i in[0..orderList.length - 1] by 1
          id = orderList[i]
          @msa.seqs[id].layer.style.paddingTop = "#{@msa.zoomer.columnSpacing}px"
          frag.appendChild @msa.seqs[id].layer

        @canvas.appendChild frag
      return @canvas

    # recolors all subchilds stage
    recolorStage: =>
      @msa.selmanager.cleanup()

      textVisibilityChanged = false
      if @internalTextDisplay isnt @msa.zoomer.isTextVisible()
        textVisibilityChanged = true
        @internalTextDisplay = @msa.zoomer.isTextVisible()

      # all columns
      for key,curRow of @msa.seqs
        currentLayer = curRow.layer
        # TODO: redundant
        currentLayer.style.height = "#{@msa.zoomer.columnHeight}px"

        for i in [0..@elements.length - 1] by 1
          @elements[i].redraw currentLayer.childNodes[i], curRow.tSeq, textVisibilityChanged
