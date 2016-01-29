var Visibility;
var Model = require("backbone-thin").Model;

// visible areas
module.exports = Visibility = Model.extend({

  defaults: {sequences: true,
    markers: true,
    metacell: false,
    conserv: false,
    overviewbox: false,
    seqlogo: false,
    gapHeader: false,
    leftHeader: true,

    // about the labels
    labels: true,
    labelName: true,
    labelId: true,
    labelPartition: false,
    labelCheckbox: false,

    // meta stuff
    metaGaps: true,
    metaIdentity: true,
    metaLinks: true
    },

  constructor: function(attributes,options) {
    this.calcDefaults(options.model);
    return Model.apply(this, arguments);
  },

  initialize: function() {

    this.listenTo( this, "change:metaLinks change:metaIdentity change:metaGaps", (function() {
      return this.trigger("change:metacell");
    }), this
    );

    this.listenTo( this, "change:labelName change:labelId change:labelPartition change:labelCheckbox", (function() {
      return this.trigger("change:labels");
    }), this
    );

    return this.listenTo( this,"change:markers change:conserv change:seqlogo change:gapHeader", (function() {
      return this.trigger("change:header");
    }), this
    );
  },

  calcDefaults: function(seqs) {
    if (seqs.length > 0) {
      var seq = seqs.at(0);
      var ids = seq.get("ids");
      if (ids !== undefined && Object.keys(ids).length === 0) {
        return this.defaults.metaLinks = false;
      }
    }
  }
});
