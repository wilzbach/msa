var MSA = require("./msa");


module.exports = window.msa = function() {
  var msa = function(args) {
    return MSA.apply(this, args);
  };
  msa.prototype = MSA.prototype;
  return new msa(arguments);
};

module.exports.msa = MSA;

// models
module.exports.model = require("./model");

// extra plugins, extensions
module.exports.menu = require("./menu");
module.exports.utils = require("./utils");

// probably needed more often
module.exports.selection = require("./g/selection/Selection");
module.exports.selcol = require("./g/selection/SelectionCol");
module.exports.view = require("backbone-viewj");
module.exports.boneView = require("backbone-childs");

// convenience
module.exports._ = require('underscore');
module.exports.$ = require('jbone');

// parser (are currently bundled - so we can also expose them)
module.exports.io = {};
module.exports.io.xhr = require('xhr');
module.exports.io.fasta = require('biojs-io-fasta');
module.exports.io.clustal = require('biojs-io-clustal');
module.exports.io.gff = require('biojs-io-gff');

module.exports.version = "0.2.0";
