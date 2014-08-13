Colorator = require "./colorator"
Ordering = require "./ordering"
Utils = require "./utils/general"
Eventhandler = require "biojs-events"
selection = require "./selection/index"
Zoomer = require "./zoomer"
SeqMgr = require "./seqmgr"
Logger = require "./utils/logger"
DomStage = require "./stage/domStage"
TilesStage = require "./tiles/tileStage.coffee"
SeqMarker = require "./dom/seqmarker"
Arrays = require "./utils/arrays"

class MSA

  # @param [String] divID (or reference to a DOM element)
  # @param [SeqArray] seqs Array of sequences for initlization
  # @param [Dict] conf user config (will overwrite the default config
  constructor: (divName, seqsInit, conf) ->

    # merge this class with the event class
    Eventhandler.mixin MSA.prototype

    # merge the config
    @_loadDefaultConfig(conf)

    # support strID and reference
    if typeof divName is "string"
      @container = document.getElementById divName
    else
      @container = divName

    @container.className += " biojs_msa_div"

    @_initPlugins()
    @_initListeners()
    @_loadStage()

    # load the sequences
    @addSeqs seqsInit if seqsInit?

  # loads all available plugins
  _initPlugins: ->

    @colorscheme = new Colorator()
    @ordering = new Ordering()

    @log = new Logger().log
    @selmanager = new selection.SelectionManager this

    @zoomer = new Zoomer(this)

    @seqs = []
    @seqmgr = new SeqMgr(this)

    @plugs = {}
    @plugsDOM = {}

    # plugins
    if @config.visibleElements.ruler
      @marker = new SeqMarker this
      @plugs["marker"] = @marker

    if @config.allowRectSelect
      @plugs["rect_select"] = new selection.RectangularSelect this

  # loads the sequence stage
  # e.g. DOM or CanvasTiles
  _loadStage: ->
    # choose type of stage
    if @config.speed
      @stage =  new TilesStage this
    else
      @stage =  new DomStage this
    @plugs["stage"] = @stage


  # registers event listeners
  _initListeners: ->

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

      start = new Date().getTime()
      node = entry.draw()
      end = new Date().getTime()
      #console.log "Plugin[#{key}] drawing time: #{(end - start)} ms"

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
    @_draw()
    @.trigger "redrawEvent"

  # TODO: do we create memory leaks here?
  _resetContainer: ->
    Utils.removeAllChilds @container

  # merges the default config
  # with the user config
  _loadDefaultConfig: (conf) ->

    @config = conf

    defaultConf = {
      visibleElements: {
        labels: true, seqs: true, menubar: true, ruler: true,
        features: false,
        allowRectSelect: false,
        speed: false,
      },
      registerMoveOvers: false,
      autofit: true,
      keyevents: false,
      prerender: false,
    }

    if @config?
      Arrays.recursiveDictFiller defaultConf, @config
    else
      @config = defaultConf

module.exports = MSA
