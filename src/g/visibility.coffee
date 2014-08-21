Model = require("backbone").Model

# visible areas
module.exports = Visibility = Model.extend

  defaults:
    sequences: true
    markers: true
    metacell: false
    conserv: true


    labels: true
    labelName: false
    labelId: true
