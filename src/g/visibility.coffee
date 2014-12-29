Model = require("backbone-thin").Model

# visible areas
module.exports = Visibility = Model.extend

  defaults:
    sequences: true
    markers: true
    metacell: false
    conserv: false
    overviewbox: false
    seqlogo: false
    gapHeader: false
    leftHeader: true

    # about the labels
    labels: true
    labelName: true
    labelId: true
    labelPartition: false
    labelCheckbox: false

    # meta stuff
    metaGaps: true
    metaIdentity: true
    metaLinks: true

  initialize: ->

    @listenTo @, "change:metaLinks change:metaIdentity change:metaGaps", ->
      @trigger "change:metacell"
    , @

    @listenTo @, "change:labelName change:labelId change:labelPartition change:labelCheckbox", ->
      @trigger "change:labels"
    , @

    @listenTo @,"change:markers change:conserv change:seqlogo change:gapHeader", ->
      @trigger "change:header"
    , @
