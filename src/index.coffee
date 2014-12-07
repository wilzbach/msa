MSA = require("./msa")

module.exports = ->
  msa = (args) ->
    MSA.apply @, args
  msa:: = MSA::
  new msa arguments

module.exports.msa = MSA

# models
module.exports.model = require("./model")

# extra plugins, extensions
module.exports.menu = require("./menu")
module.exports.utils = require("./utils")

# probably needed more often
module.exports.selection = require("./g/selection/Selection")
module.exports.selcol = require("./g/selection/SelectionCol")
module.exports.view = require("backbone-viewj")
module.exports.boneView = require("backbone-childs")

# convenience
module.exports._ = require 'underscore'
module.exports.$ = require 'jbone'

module.exports.version = "0.2.0"
