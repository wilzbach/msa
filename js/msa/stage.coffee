define ["./utils"], (Utils) ->
  class Stage

    constructor: (@msa) ->
      # unique stage id
      @ID =  String.fromCharCode(65 + Math.floor(Math.random() * 26))
      @globalID = 'biojs_msa_' + @ID

      @canvas = document.createElement "div"
      @canvas.setAttribute "id","#{@globalID}_canvas"
      @canvas.setAttribute "class", "biojs_msa_stage"

    draw: ->

      orderList = @msa.ordering.getSeqOrder(@msa.seqs)

      # consistency check
      if orderList.length != Object.size(@msa.seqs)
        console.log "Length of the input array "+ orderList.length +
          " does not match with the real world " + Object.size(@msa.seqs)
        return

      # prepare stage
      frag = document.createDocumentFragment()
      for i in[0..orderList.length - 1] by 1
        id = orderList[i]
        @msa.seqs[id].layer.style.paddingTop = "#{@columnSpacing}px"
        frag.appendChild @msa.seqs[id].layer

      # reset stage
      Utils.removeAllChilds @canvas
      @canvas.appendChild frag

      #TODO: width update
      @canvas.width = @msa.zoomer.seqOffset + @msa._nMax * @msa.zoomer.columnWidth

      return @canvas
