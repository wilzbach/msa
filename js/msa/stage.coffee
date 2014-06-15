define ["./utils"], (Utils) ->
  class Stage

    constructor: (@msa) ->
      # unique stage id
      @ID =  String.fromCharCode(65 + Math.floor(Math.random() * 26))
      @globalID = 'biojs_msa_' + @ID

      @canvas = document.createElement "div"
      @canvas.setAttribute "id","#{@globalID}_canvas"
      @canvas.setAttribute "class", "biojs_msa_stage"

    width: (n) ->
      return @msa.zoomer.seqOffset + n * @msa.zoomer.columnWidth

    draw: ->

      orderList = @msa.ordering.getSeqOrder(@msa.seqs)

      unless orderList?
        console.log "empty seq stage"
        return

      # consistency check
      if orderList.length != Object.size(@msa.seqs)
        console.log "Length of the input array "+ orderList.length +
          " does not match with the real world " + Object.size(@msa.seqs)
        return

      # prepare stage
      frag = document.createDocumentFragment()
      for i in[0..orderList.length - 1] by 1
        id = orderList[i]
        @msa.seqs[id].layer.style.paddingTop = "#{@msa.zoomer.columnSpacing}px"
        frag.appendChild @msa.seqs[id].layer

      # reset stage
      Utils.removeAllChilds @canvas
      @canvas.appendChild frag

      @canvas.width = @width @msa._nMax

      return @canvas
