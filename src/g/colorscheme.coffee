Colors = require("biojs-util-colorschemes")

Model = require("backbone-thin").Model

# this is an example of how one could color the MSA
# feel free to create your own color scheme in the /css/schemes folder
module.exports = Colorator = Model.extend

  defaults:
    scheme: "taylor" # name of your color scheme
    colorBackground: true # otherwise only the text will be colored
    showLowerCase: true # used to hide and show lowercase chars in the overviewbox
    opacity: 0.6 # opacity for the residues

  initialize: (seqs, stat) ->
    @colors = new Colors(
      seqs: seqs
      conservation: ->
        stat.scale(stat.conservation())
    )
    stat.on "reset", =>
      if @getSelectedColorScheme().type is "dyn"
        @getSelectedColorScheme().reset()

  # You can enter your own color scheme here
  addStaticColorScheme: (dict, name) ->
    @colors.addStaticColorScheme dict,name

  addDynColorScheme: (fun, name) ->
    @colors.addStaticColorScheme fun,name

  getColorScheme: (name) ->
    @colors.getScheme name

  getSelectedColorScheme: ->
    @colors.getScheme @get("scheme")
