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

    # about the labels
    labels: true
    labelName: true
    labelId: true
    labelPartition: false
    labelCheckbox: false
