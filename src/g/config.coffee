Model = require("backbone").Model

# simple user config
module.exports = Config = Model.extend

  defaults:
    registerMouseHover: false,
    registerMouseClicks: true,
    importProxy: "https://cors-anywhere.herokuapp.com/"
    eventBus: true
