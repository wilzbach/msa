module.exports.msa = require("./msa")

# models
module.exports.model = require("./model")

# extra plugins, extensions
module.exports.algo = require("./algo")
module.exports.menu = require("./menu")
module.exports.utils = require("./utils")

# probably needed more often
module.exports.selection = require("./g/selection/Selection")
module.exports.view = require("./bone/view")
module.exports.pluginator = require("./bone/pluginator")

# convenience
module.exports._ = require 'underscore'
module.exports.$ = require 'jbone'

module.exports.version = "0.1.0"
