Model = require("backbone").Model

# simple user config
module.exports = Config = Model.extend

  defaults:
    registerMouseEvents: false,
    autofit: true,
    #keyevents: false,


#  defaultConf = {
#    visibleElements: {
#      labels: true, seqs: true, menubar: true, ruler: true,
#      features: false,
#      allowRectSelect: false,
#      speed: false,
#    },

