# models
SeqCollection = require "./model/SeqCollection"

# globals
Colorator = require "./g/colorscheme"
Columns = require "./g/columns"
Config = require "./g/config"
SelCol = require "./g/selection/SelectionCol"
Visibility = require "./g/visibility"
VisOrdering = require "./g/visOrdering"
Zoomer = require "./g/zoomer"

# MV from backbone
boneView = require("backbone-childs")
Eventhandler = require "biojs-events"

# MSA views
Stage = require "./views/Stage"

# statistics
Stats = require "biojs-stat-seqs"

# utils
FileHelper = require "./utils/file"

# opts is a dictionary consisting of
# @param el [String] id or reference to a DOM element
# @param seqs [SeqArray] Array of sequences for initlization
# @param conf [Dict] user config
# @param vis [Dict] config of visible views
# @param zoomer [Dict] display settings like columnWidth
module.exports = boneView.extend

  initialize: (data) ->

    # check for default arrays
    data.colorscheme = {} unless data.colorscheme?
    data.columns = {} unless data.columns?
    data.conf = {} unless data.conf?
    data.vis = {} unless data.vis?
    data.visorder = {} unless data.visorder ?
    data.zoomer = {} unless data.zoomer?

    # g is our global Mediator
    @g = Eventhandler.mixin {}

    if data.seqs is undefined or data.seqs.length is 0
      console.log "warning. empty seqs."

    # load seqs and add subviews
    @seqs = new SeqCollection data.seqs

    # populate it and init the global models
    @g.config = new Config data.conf
    @g.selcol = new SelCol [],{g:@g}
    @g.vis = new Visibility data.vis
    @g.visorder = new VisOrdering data.visorder
    @g.zoomer = new Zoomer data.zoomer,{g:@g}

    # stats
    pureSeq = @seqs.pluck("seq")
    @g.stats = new Stats @seqs
    @g.stats.alphabetSize = @g.config.get "alphabetSize"
    @g.columns = new Columns data.columns,@g.stats  # for action on the columns like hiding

    # depending config
    @g.colorscheme = new Colorator data.colorscheme, pureSeq, @g.stats

    @addView "stage",new Stage {model: @seqs, g: @g}
    @el.setAttribute "class", "biojs_msa_div"

    if @g.config.get("eventBus") is true
      @startEventBus()

    if @g.config.get "dropImport"
      events =
        "dragover": @dragOver
        "drop": @dropFile
      @delegateEvents events

  dragOver: (e) ->
    # prevent the normal browser actions
    e.preventDefault()
    e.target.className = 'hover'
    false

  dropFile: (e) ->
    e.preventDefault()
    files = e.target.files || e.dataTransfer.files
    for i in [0..files.length - 1] by 1
      file = files[i]
      reader = new FileReader()
      #attach event handlers here...
      reader.onload = (evt) =>
        seqs = FileHelper.parseText evt.target.result
        @seqs.reset seqs
        @g.config.set "url", "dragimport"
        @g.trigger "url:dragImport"
      fileName = file.name
      reader.readAsText file
      # reading more than one file doesnt make sense atm
      break
    return false

  startEventBus: ->
    busObjs = ["config", "columns", "colorscheme", "selcol" ,"vis", "visorder", "zoomer"]
    for key in busObjs
      @_proxyToG key

  _proxyToG: (key) ->
    @listenTo @g[key], "all",(name,prev,now,opts) ->
      # suppress duplicate events
      return if name is "change"
      # backbone uses the second argument for the next value -> swap
      if opts?
        @g.trigger(key + ":" + name,now,opts)
      else
        @g.trigger(key + ":" + name,now)

  render: ->
    @renderSubviews()
    @g.vis.set "loaded", true
    @
