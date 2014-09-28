Model = require("backbone").Model

# visible areas
module.exports = Visibility = Model.extend

  defaults:

    # for the Stage
    overviewBox: 30
    headerBox: -1
    alignmentBody: 0
