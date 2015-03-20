# models
SeqCollection = require "./model/SeqCollection"

# globals
Colorator = require "./g/colorscheme"
Columns = require "./g/columns"
Config = require "./g/config"
Package = require "./g/package"
SelCol = require "./g/selection/SelectionCol"
User = require "./g/user"
Visibility = require "./g/visibility"
VisOrdering = require "./g/visOrdering"
Zoomer = require "./g/zoomer"

# MV from backbone
boneView = require("backbone-childs")
Eventhandler = require "biojs-events"

# MSA views
Stage = require "./views/Stage"

# statistics
Stats = require "stat.seqs"

# utils
$ = require("jbone")
FileHelper = require "./utils/file"
TreeHelper = require "./utils/tree"
ProxyHelper = require "./utils/proxy"

# opts is a dictionary consisting of
# @param el [String] id or reference to a DOM element
# @param seqs [SeqArray] Array of sequences for initlization
# @param conf [Dict] user config
# @param vis [Dict] config of visible views
# @param zoomer [Dict] display settings like columnWidth
module.exports = boneView.extend

  initialize: (data) ->

    data = {} unless data?
    # check for default arrays
    data.colorscheme = {} unless data.colorscheme?
    data.columns = {} unless data.columns?
    data.conf = {} unless data.conf?
    data.vis = {} unless data.vis?
    data.visorder = {} unless data.visorder ?
    data.zoomer = {} unless data.zoomer?

    # g is our global Mediator
    @g = Eventhandler.mixin {}

    # load seqs and add subviews
    @seqs = new SeqCollection data.seqs, @g

    # populate it and init the global models
    @g.config = new Config data.conf
    @g.package = new Package @g
    @g.selcol = new SelCol [],{g:@g}
    @g.user = new User()
    @g.vis = new Visibility data.vis, {model: @seqs}
    @g.visorder = new VisOrdering data.visorder
    @g.zoomer = new Zoomer data.zoomer,{g:@g, model: @seqs}

    # debug mode
    if window.location.hostname is "localhost"
      @g.config.set "debug", true

    # stats
    pureSeq = @seqs.pluck("seq")
    @g.stats = new Stats @seqs
    @g.stats.alphabetSize = @g.config.get "alphabetSize"
    @g.columns = new Columns data.columns,@g.stats  # for action on the columns like hiding

    # depending config
    @g.colorscheme = new Colorator data.colorscheme, pureSeq, @g.stats

    # more init
    @g.zoomer.setEl @el, @seqs

    @addView "stage",new Stage {model: @seqs, g: @g}
    @el.setAttribute "class", "biojs_msa_div"

    # utils
    @u = {}
    @u.file = new FileHelper @
    @u.proxy = new ProxyHelper g: @g
    @u.tree = new TreeHelper @

    if @g.config.get("eventBus") is true
      @startEventBus()

    if @g.config.get "dropImport"
      events =
        "dragover": @dragOver
        "drop": @dropFile
      @delegateEvents events

    if data.importURL
      @u.file.importURL data.importURL, =>
        @render()

    # bootstraps the menu bar by default -> destroys modularity
    if data.bootstrapMenu
      menuDiv = document.createElement('div')
      wrapperDiv = document.createElement('div')
      unless @el.parentNode
        wrapperDiv.appendChild menuDiv
        wrapperDiv.appendChild @el
      else
        @el.parentNode.replaceChild(wrapperDiv, @el)
        wrapperDiv.appendChild menuDiv
        wrapperDiv.appendChild @el

      defMenu = new msa.menu.defaultmenu(
        el: menuDiv,
        msa: @
      )
      defMenu.render()

    $(window).on("resize", (e) =>
      f = ->
        @g.zoomer.autoResize()
      setTimeout f.bind(@), 5
    )

  dragOver: (e) ->
    # prevent the normal browser actions
    e.preventDefault()
    e.target.className = 'hover'
    false

  dropFile: (e) ->
    e.preventDefault()
    files = e.target.files || e.dataTransfer.files
    @u.file.importFiles files
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
        @g.trigger(key + ":" + name,now,prev,opts)
      else
        @g.trigger(key + ":" + name,now,prev)

  render: ->
    if @seqs is undefined or @seqs.length is 0
      console.log "warning. empty seqs."
    @renderSubviews()
    @g.vis.set "loaded", true
    @
