Model = require("backbone-thin").Model
FeatureCol = require "./FeatureCol"

module.exports = Sequence = Model.extend

  defaults:
    name: ""
    id: ""
    seq: ""

  initialize: ->
    # residues without color
    @.set "grey", []
    @.set "features", new FeatureCol()
