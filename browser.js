if (typeof biojs === 'undefined') {
  biojs = {};
}
if (typeof biojs.vis === 'undefined') {
  biojs.vis = {};
}
// use two namespaces
window.msa = biojs.vis.msa = module.exports = require('./index');

// TODO: how should this be bundled

if (typeof biojs.io === 'undefined') {
  biojs.io = {};
}
// just bundle the two parsers
window.biojs.io.fasta = require("biojs-io-fasta");
window.biojs.io.clustal = require("biojs-io-clustal");

// simulate standalone flag
window.biojsVisMsa = window.msa;
