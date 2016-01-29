var Package;
var Loader = require("../utils/loader");
var Model = require("backbone-thin").Model;

module.exports = Package = Model.extend({

  initialize: function(g) {
    return this.g = g;
  },

  development:
    {"msa-tnt": "/node_modules/msa-tnt/build/bundle.js",
    "biojs-io-newick": "/node_modules/biojs-io-newick/build/biojs-io-newick.min.js"
    },

  // loads a package into the MSA component (if it is not available yet)
  loadPackage: function(pkg, cb) {
    try {
      var p = require(pkg);
      return cb(p);
    } catch (error) {
      return Loader.loadScript(this._pkgURL(pkg), cb);
    }
  },

  // loads multiple packages and calls the cb if all packages are loaded
  loadPackages: function(pkgs, cb) {
      var cbs = Loader.joinCb( (function() {
        return cb();
      }
      ), pkgs.length
      );
      return pkgs.forEach((pkg) => {
        return this.loadPackage(pkg, cbs);
      });
  },

  // internal method to get the URL for a package
  _pkgURL: function(pkg) {

    if (this.g.config.get("debug")) {
      var url = this.development[pkg];
    } else {
      url = `http://wzrd.in/bundle/${pkg}@latest`;
    }

    return url;
  }
});
