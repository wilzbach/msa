Model = require("backbone-thin").Model
FeatureCol = require "./FeatureCol"

module.exports = Sequence = Model.extend

  defaults:
    name: ""
    id: ""
    seq: ""
    height: 1

  initialize: ->
    # residues without color
    @.set "grey", []
    unless @.get("features")?
      @.set "features", new FeatureCol()
