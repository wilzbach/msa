# models
SeqCollection = require "./model/SeqCollection"

# globals
Colorator = require "./g/colorator"
Columns = require "./g/columns"
Config = require "./g/config"
SelCol = require "./g/selection/SelectionCol"
Visibility = require "./g/visibility"
Zoomer = require "./g/zoomer"

# MV from backbone
view = require("./bone/view")
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
MSAView = view.extend

  events: {
    # "mouseout": "cleanup"
    "dblclick": "cleanup"
  }

  initialize: (data) ->

    # check for default arrays
    data.conf = {} unless data.conf?
    data.vis = {} unless data.vis?
    data.zoomer = {} unless data.zoomer?

    # g is our global Mediator
    @g = Eventhandler.mixin {}

    # populate it and init the models
    @g.config = new Config data.conf
    @g.columns = new Columns() # for action on the columns like hiding
    @g.colorscheme = new Colorator()
    @g.selcol = new SelCol [],{g:@g}
    @g.vis = new Visibility data.vis
    @g.zoomer = new Zoomer data.zoomer

    # load seqs and add subviews
    @seqs = new SeqCollection data.seqs
    @addView "stage",new Stage {model: @seqs, g: @g}

    @el.setAttribute "class", "biojs_msa_div"

  render: ->
    @.trigger "hello"
    @renderSubviews()
    @

# mix and shake
pluginator.mixin MSAView::
module.exports = MSAView
