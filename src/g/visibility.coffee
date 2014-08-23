Model = require("backbone").Model

# visible areas
module.exports = Visibility = Model.extend

  defaults:
    sequences: true
    markers: true
    metacell: false
    conserv: true
    overviewbox: false


    labels: true
    labelName: true
    labelId: true
