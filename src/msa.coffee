Eventhandler = require "biojs-events"

# sequence
SeqMgr = require "./seqManager"

# working with seqs
Colorator = require "./coloring/colorator"
Ordering = require "./ordering"
selection = require "./selection/index"

# utils
Zoomer = require "./zoomer"
Config = require "./config"

view = require("./views/view")
pluginator = require("./views/pluginator")

Stage = require "./views/Stage"

# opts consists ow
# @param [String] el (id or reference to a DOM element)
# @param [SeqArray] seqs Array of sequences for initlization
# @param [Dict] conf user config (will overwrite the default config
MSAView = view.extend

  events: {
    # "mouseout": "cleanup"
    "dblclick": "cleanup"
  }

  initialize: (data) ->
    console.log data

    # program args
    data.conf = {} unless data.conf?
    @seqs = data.seqs

    @el.setAttribute "class", "biojs_msa_div"

    # shared globals
    @g = {}
    # merge the config
    @g.config = Config data.conf
    @g.colorscheme = new Colorator this
    @g.ordering = new Ordering()
    @g.selmanager = new selection.SelectionManager this
    @g.zoomer = new Zoomer(this)

    @g.zoomer.setZoomLevel 10

    #@seqmgr = new SeqMgr()
    # seq reference - access is more convenient
    #@seqs = @seqmgr.seqs

    @addView "stage",new Stage {seqs: @seqs, g: @g}

    #if @config.allowRectSelect
    #@plugs["rect_select"] = new selection.RectangularSelect this

  render: ->
    @.trigger "hello"
    @renderSubviews()
    @

  # adds one or multiple sequences
  # @param tSeqs [[Sequences]] array of sequences you want to add
  addSeqs: (tSeqs) ->
    @zoomer.autofit tSeqs if @g.zoomer?
    @seqmgr.addSeqs tSeqs
    # TODO: do we want to draw the entire MSA not only the stage)
    @_draw()

  cleanup: ->
    @g.selmanager.cleanup()

# mix and shake
pluginator.mixin MSAView::
module.exports = MSAView
