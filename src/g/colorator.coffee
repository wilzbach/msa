#Utils = require "../utils/color"
Model = require("backbone").Model

# this is an example of how one could color the MSA
# feel free to create your own color scheme
module.exports = Colorator = Model.extend

  defaults:
    scheme: "taylor"
    colorBackground: true # otherwise only the text will be colored
    showLowerCase: true
