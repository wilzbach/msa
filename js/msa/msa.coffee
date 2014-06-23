define ["cs!msa/colorator", "cs!msa/ordering", "msa/utils",
  "cs!msa/eventhandler", "msa/selection/main", "cs!msa/zoomer",
  "cs!msa/seqmgr", "cs!msa/logger", "cs!msa/stage/stage", "cs!msa/seqmarker", "cs!utils/arrays"],(Colorator,
  Ordering, Utils, Eventhandler, selection, Zoomer, SeqMgr, Logger,
  Stage, SeqMarker, arrays) ->

  class MSA

    constructor: (divName, seqsInit, conf) ->

      @_loadDefaultConfig(conf)
      @container = document.getElementById divName

      @colorscheme = new Colorator()
      @ordering = new Ordering()

      @log = new Logger()
      @events = new Eventhandler @log.log
      @selmanager = new selection.SelectionManager this, @events

      @zoomer = new Zoomer(this)

      @seqs = []
      @seqmgr = new SeqMgr(this)

      @plugs = {}
      @plugsDOM = {}

      # plugins
      if @config.visibleElements.ruler
        @marker = new SeqMarker this
        @plugs["marker"] = @marker

      # essential stage
      @stage =  new Stage this
      @plugs["stage"] = @stage

      @addSeqs seqsInit if seqsInit?

      # TODO: rect select
      #@plugs.push  new RectangularSelect()

      # post hooks
      if @config.registerMoveOvers
        @container.addEventListener 'mouseout', =>
          @selmanager.cleanup()

      @container.addEventListener 'dblclick', =>
        @selmanager.cleanup()

    addSeqs: (tSeq) ->
      @stage.addSeqs tSeq
      # TODO: do we want to draw the entire MSA not only the stage)
      @_draw()

    # TODO: use a user ordering
    addPlugin: (plugin, key) ->
      @plugs[key] = plugin
      @_draw()

    _draw: ->

      @_nMax = @zoomer.getMaxLength @seqs

      #@zoomer.autofit() if @config.autofit

      frag = document.createDocumentFragment()

      # sort plugs
      plugsSort = []
      plugsSort.push key for key of @plugs
      plugsSort.sort()

      # load plugins
      for key in plugsSort
        entry = @plugs[key]
        node = entry.draw()
        if node
          frag.appendChild node
          @plugsDOM[key] = node

      # replace the current container with the new
      Utils.removeAllChilds @container
      @container.appendChild frag

    redraw: (plugin) ->
      newDOM = @plugs[plugin].draw()

      plugDOM= @plugsDOM[plugin]
      # better use container than parentNode
      plugDOM.parentNode.replaceChild newDOM, plugDOM

      @plugsDOM[plugin] = newDOM


    redrawContainer: ->
      @plugs['stage'].reset()
      @_resetContainer()

    # TODO: do we create memory leaks here?
    _resetContainer: ->
      Utils.removeAllChilds @container

    _loadDefaultConfig: (conf) ->

      @config = conf

      defaultConf = {
        visibleElements: {
          labels: true, seqs: true, menubar: true, ruler: true,
          features: false
        },
        registerMoveOvers: false,
        autofit: true,
      }

      if @config?
        arrays.recursiveDictFiller defaultConf, @config
      else
        @config = defaultConf

