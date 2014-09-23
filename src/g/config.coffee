Model = require("backbone").Model

# simple user config
module.exports = Config = Model.extend

  defaults:
    registerMouseHover: false,
    registerMouseClicks: true,
    importProxy: "http://www.corsproxy.com/"
    eventBus: true
