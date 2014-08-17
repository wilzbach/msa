Eventhandler = require "biojs-events"

# models
SeqCollection = require "./model/SeqCollection"

# global
Colorator = require "./g/colorator"
Columns = require "./g/columns"
SelCol = require "./g/selection/SelectionCol"

# utils
Zoomer = require "./g/zoomer"
Config = require "./config"

view = require("./bone/view")
pluginator = require("./bone/pluginator")

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

    # program args
    data.conf = {} unless data.conf?
    data.zoomer = {} unless data.zoomer?

    @el.setAttribute "class", "biojs_msa_div"

    # g is our global Mediator
    @g = Eventhandler.mixin {}

    # merge the config
    @g.config = new Config data.conf
    @g.columns = new Columns()
    @g.colorscheme = new Colorator()
    @g.selcol = new SelCol [],{g:@g}
    @g.zoomer = new Zoomer data.zoomer

    @seqs = new SeqCollection data.seqs

    @addView "stage",new Stage {model: @seqs, g: @g}

    #if @config.allowRectSelect - terribly broken
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
