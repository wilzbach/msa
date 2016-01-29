var Columns;
var Model = require("backbone-thin").Model;
var _ = require("underscore");

// model for column properties (like their hidden state)
module.exports = Columns = Model.extend({

  initialize: function(o,stat) {
    // hidden columns
    if (!(this.get("hidden") != null)) { this.set("hidden", []); }
    return this.stats = stat;
  },

  // assumes hidden columns are sorted
  // @returns n [int] number of hidden columns until n
  calcHiddenColumns: function(n) {
    var hidden = this.get("hidden");
    var newX = n;
    for (var j = 0, i; j < hidden.length; j++) {
      i = hidden[j];
      if (i <= newX) {
        newX++;
      }
    }
    return newX - n;
  }
});
