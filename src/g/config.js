var Config;
var Model = require("backbone-thin").Model;

// simple user config
module.exports = Config = Model.extend({

  defaults:
    {registerMouseHover: false,
    registerMouseClicks: true,
    importProxy: "http://crossorigin.me/",
    eventBus: true,
    alphabetSize: 20,
    dropImport: false,
    debug: false,
    hasRef: false, // hasReference
    bootstrapMenu: false,
    manualRendering: false // not recommended to turn on
    }
});
