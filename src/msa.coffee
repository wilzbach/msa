Eventhandler = require "biojs-events"

# sequence
SeqMarker = require "./dom/seqmarker"
SeqMgr = require "./seqManager"

# working with seqs
Colorator = require "./coloring/colorator"
Ordering = require "./ordering"
selection = require "./selection/index"

# stages
DomStage = require "./stage/domStage"
#TilesStage = require "./tiles/tileStage.coffee"

# utils
Utils = require "./utils/general"
Zoomer = require "./zoomer"
Logger = require "./utils/logger"
Config = require "./config"


class MSA

  # @param [String] divID (or reference to a DOM element)
  # @param [SeqArray] seqs Array of sequences for initlization
  # @param [Dict] conf user config (will overwrite the default config
  constructor: (div, seqsInit, conf) ->

    # merge the config
    @config = Config conf

    # support strID and reference
    if typeof div is "string"
      @container = document.getElementById div
    else
      @container = div

    @container.className = "" unless @container.className?
    @container.className += " biojs_msa_div"

    @_initPlugins()
    @_initListeners()
    @_loadStage()

    # load the sequences
    @addSeqs seqsInit if seqsInit?

  # loads all available plugins
  _initPlugins: ->

    @colorscheme = new Colorator this
    @ordering = new Ordering()

    @log = new Logger().log
    @selmanager = new selection.SelectionManager this

    @zoomer = new Zoomer(this)

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

    @seqmgr = new SeqMgr @stage
    # reference - access is more convenient
    @seqs = @seqmgr.seqs

  # registers event listeners
  _initListeners: ->

    if @config.registerMoveOvers
      @container.addEventListener 'mouseout', =>
        @selmanager.cleanup()

    @container.addEventListener 'dblclick', =>
      @selmanager.cleanup()

  # adds one or multiple sequences
  # @param tSeqs [[Sequences]] array of sequences you want to add
  addSeqs: (tSeqs) ->
    @zoomer.autofit tSeqs if @zoomer?
    @seqmgr.addSeqs tSeqs
    # TODO: do we want to draw the entire MSA not only the stage)
    @_draw()

  # adds a plugin
  # @param plugin [Plugin] provides draw
  # @param id [String] Id for later access
  addPlugin: (plugin, key) ->
    unless plugin?
      throw "Invalid plugin. "
    # fallback for custom ordering
    plugin.ordering = key unless plugin.ordering?
    @plugs[key] = plugin
    @_draw()

  # draws the entire component
  _draw: ->

    @_nMax = @zoomer.getMaxLength @seqs
    frag = document.createDocumentFragment()

    plugsSort = @_sortPlugins()

    # load plugins
    for key in plugsSort
      entry = @plugs[key]

      start = new Date().getTime()
      node = entry.draw()
      #console.log "Plugin[#{key}] drawing time: #{(new Date().getTime() - start)} ms"

      if node
        frag.appendChild node
        @plugsDOM[key] = node

    # replace the current container with the new
    Utils.removeAllChilds @container
    @container.appendChild frag

  # sorts the plugins after their given ordering
  # @returns sorted list of keys (of the plugins)
  _sortPlugins: ->
    # sort plugs
    plugsSort = []
    plugsSort.push key for key of @plugs
    plugsSort.sort (a,b) =>
        nameA = @plugs[a].ordering
        nameB = @plugs[b].ordering
        return -1 if nameA < nameB
        return 1  if nameA > nameB
        0
    return plugsSort

  # redraws a special plugin
  # @param id [String] Id of the plugin
  redrawPlugin: (plugin) ->
    newDOM = @plugs[plugin].draw()

    plugDOM= @plugsDOM[plugin]
    # better use container than parentNode
    plugDOM.parentNode.replaceChild newDOM, plugDOM
    @plugsDOM[plugin] = newDOM

  # total redraw of the entire component
  redraw: ->
    @plugs['stage'].reset()
    @_resetContainer()
    @_draw()
    @.trigger "redrawEvent"

  # TODO: do we create memory leaks here?
  _resetContainer: ->
    Utils.removeAllChilds @container

# merge this class with the event class
Eventhandler.mixin MSA.prototype
module.exports = MSA
