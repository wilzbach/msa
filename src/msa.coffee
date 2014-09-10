# models
SeqCollection = require "./model/SeqCollection"

# globals
Colorator = require "./g/colorator"
Consensus = require "./g/consensus"
Columns = require "./g/columns"
Config = require "./g/config"
SelCol = require "./g/selection/SelectionCol"
Visibility = require "./g/visibility"
VisOrdering = require "./g/visOrdering.coffee"
Zoomer = require "./g/zoomer"

# MV from backbone
pluginator = require("./bone/pluginator")
Eventhandler = require "biojs-events"

# MSA views
Stage = require "./views/Stage"

# opts is a dictionary consisting of
# @param el [String] id or reference to a DOM element
# @param seqs [SeqArray] Array of sequences for initlization
# @param conf [Dict] user config
# @param vis [Dict] config of visible views
# @param zoomer [Dict] display settings like columnWidth
module.exports = pluginator.extend

  initialize: (data) ->

    # check for default arrays
    data.columns = {} unless data.columns?
    data.conf = {} unless data.conf?
    data.vis = {} unless data.vis?
    data.visorder = {} unless data.visorder ?
    data.zoomer = {} unless data.zoomer?

    # g is our global Mediator
    @g = Eventhandler.mixin {}

    # load seqs and add subviews
    @seqs = new SeqCollection data.seqs

    # populate it and init the global models
    @g.config = new Config data.conf
    @g.consensus = new Consensus()
    @g.columns = new Columns data.columns  # for action on the columns like hiding
    @g.colorscheme = new Colorator()
    @g.selcol = new SelCol [],{g:@g}
    @g.vis = new Visibility data.vis
    @g.visorder = new VisOrdering data.visorder
    @g.zoomer = new Zoomer data.zoomer

    @addView "stage",new Stage {model: @seqs, g: @g}
    @el.setAttribute "class", "biojs_msa_div"

  render: ->
    @renderSubviews()
    @
