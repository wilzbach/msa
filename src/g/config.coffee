Model = require("backbone").Model

# simple user config
module.exports = Config = Model.extend

  defaults:
    registerMouseEvents: false,
    importProxy: "http://www.corsproxy.com/"
