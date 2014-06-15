define ["cs!msa/colorator", "cs!msa/ordering", "./utils",
  "cs!msa/eventhandler", "./selection/main", "cs!msa/zoomer",
  "cs!msa/seqmgr", "cs!msa/logger", "cs!msa/stage", "cs!msa/seqmarker"],(Colorator,
  Ordering, Utils, Eventhandler, selection, Zoomer, SeqMgr, Logger,
  Stage, SeqMarker) ->

  class MSA

    constructor: (divName, @config) ->

      @colorscheme = new Colorator()
      @ordering = new Ordering()

      @log = new Logger()
      @events = new Eventhandler(@log.log)
      @selmanager = new selection.SelectionManager(this, @events)

      @zoomer = new Zoomer()

      # support for only one argument
      @config = {} unless config?

      # TODO: better default querying
      unless @config.visibleElements
        @config.visibleElements = {
          labels: true, sequences: true, menubar: true, ruler: true
        }

      @seqs = []
      @seqmgr = new SeqMgr(this)

      @container = document.getElementById divName

      @plugs = []

      # plugins
      @marker = new SeqMarker(this)
      #@stage.appendChild(marker.createContainer())
      @plugs.push @marker

      # essential stage
      @stage =  new Stage(this)
      #@container.appendChild(@stage.initStage())
      @plugs.push @stage

      # TODO: rect select
      #@plugs.push  new RectangularSelect()

      # post hooks
      if @config.registerMoveOvers?
        @container.addEventListener 'mouseout', =>
          @selmanager.cleanup()


    addSeqs: (tSeq) ->
      @seqmgr._addSeqs tSeq
      @_draw()

    _draw: ->

      @_nMax = 0
      (@_nMax = Math.max @_nMax, value.tSeq.seq.length) for key,value of @seqs

      frag = document.createDocumentFragment()
      for entry in @plugs
        node = entry.draw()
        unless node
          #console.log "plugin #{entry.constructor.name} is hidden. "
        else
          frag.appendChild node

      # replace the current container with the new
      Utils.removeAllChilds @container
      @container.appendChild frag

    # redraws the entire MSA
    recolorEntire: ->
      @selmanager.cleanup()

      # all columns
      for curRow of @seqs
        currentLayer = @seqs[curRow].layer
        @colorscheme.colorLabel LabelBuilder.recolorLabel currentLayer.childNodes[0],@seqs[curRow].tSeq
        seqmgr.recolorRow currentLayer.childNodes[1]

    recolorRows: ->
      seqmgr.recolorRow value.layer.childNodes[1] for key,value in @seqs

    removeSeq: (id) ->
      seqs[id].layer.destroy()
      delete seqs[id]
      # reorder
      @orderSeqsAfterScheme()

    redrawEntire: ->
      tSeqs = []
      tSeqs.push @seqs[tSeq].tSeq for tSeq of @seqs

      @resetStage()
      @addSequences tSeqs

    # TODO: do we create memory leaks here?
    resetStage: ->
      Utils.removeAllChilds @stage
