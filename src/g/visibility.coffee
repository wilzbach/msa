Model = require("backbone").Model

# visible areas
module.exports = Visibility = Model.extend

  defaults:
    labels: true
    sequences: true
    markers: true
