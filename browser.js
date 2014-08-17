if (typeof biojs === 'undefined') {
  module.exports = biojs = {};
}
if (typeof biojs.vis === 'undefined') {
  module.exports = biojs.vis = {};
}
// use two namespaces
msa = biojs.vis.msa = require('./index');

// TODO: how should this be bundled
biojs.vis.easy_features = require("biojs-vis-easy_features");
