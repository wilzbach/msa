var Sequence;
var Model = require("backbone-thin").Model;
var FeatureCol = require("./FeatureCol");

module.exports = Sequence = Model.extend({

  defaults: {
    name: "",
    id: "",
    seq: "",
    height: 1,
    ref: false, // reference: the sequence used in BLAST or the consensus seq
  },

  initialize: function() {
    // residues without color
    this.set("grey", []);
    if (!(this.get("features") != null)) {
      return this.set("features", new FeatureCol());
    }
  }
});
