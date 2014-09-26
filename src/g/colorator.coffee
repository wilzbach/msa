Model = require("backbone-model").Model

# this is an example of how one could color the MSA
# feel free to create your own color scheme in the /css/schemes folder
module.exports = Colorator = Model.extend

  defaults:
    scheme: "taylor" # name of your color scheme (css suffix)
    colorBackground: true # otherwise only the text will be colored
    showLowerCase: true # used to hide and show lowercase chars in the overviewbox
    opacity: 0.6 # opacity for the residues
