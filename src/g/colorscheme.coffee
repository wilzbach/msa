Colors = require("msa-colorschemes")

Model = require("backbone-thin").Model

# this is an example of how one could color the MSA
# feel free to create your own color scheme in the /css/schemes folder
module.exports = Colorscheme = Model.extend

  defaults:
    scheme: "taylor" # name of your color scheme
    colorBackground: true # otherwise only the text will be colored
    showLowerCase: true # used to hide and show lowercase chars in the overviewbox
    opacity: 0.6 # opacity for the residues

  initialize: (data,seqs, stat) ->
    @colors = new Colors(
      seqs: seqs
      conservation: ->
        stat.scale(stat.conservation())
    )
    # the stats module sends an event every time it is refreshed
    stat.on "reset", ->
      if @getSelectedScheme().type is "dyn"
        @getSelectedScheme().reset()
    ,@

  # You can enter your own color scheme here
  addStaticScheme: (name, dict) ->
    @colors.addStaticScheme name,dict

  addDynScheme: (name, fun) ->
    @colors.addDynScheme name,fun

  getScheme: (name) ->
    @colors.getScheme name

  getSelectedScheme: ->
    @colors.getScheme @get("scheme")
