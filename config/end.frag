    //The modules for your project will be inlined above
    //this snippet. Ask almond to synchronously require the
    //module value for 'main' here and return it as the
    //value to use for the public API for the built file.


    // dirty hack to allow script loading in almond
    if (typeof window.define !== 'function' || ! window.define.amd) {
      window.almond = {};
	  window.almond.define = define;
	  window.almond.require = require;
    }

    return require('main');
}));
