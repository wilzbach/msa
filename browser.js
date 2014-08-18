if (typeof biojs === 'undefined') {
  module.exports = biojs = {};
}
if (typeof biojs.vis === 'undefined') {
  module.exports = biojs.vis = {};
}
// use two namespaces
window.msa = biojs.vis.msa = require('./index');

// TODO: how should this be bundled
biojs.vis.easy_features = require("biojs-vis-easy_features");

if (typeof biojs.io === 'undefined') {
  biojs.io = {};
}
// just bundle the two parsers
window.biojs.io.fasta = require("biojs-io-fasta");
window.biojs.io.clustal = require("biojs-io-clustal");
