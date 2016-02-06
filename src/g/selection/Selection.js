var _ = require("underscore");
var Model = require("backbone-thin").Model;

// holds the current user selection
var Selection = Model.extend({
  defaults:
    {type: "super"}


});var RowSelection = Selection.extend({
  defaults: _.extend( {}, Selection.prototype.defaults,
    {type: "row",
    seqId: ""
  }),

  inRow(seqId) {
    return seqId === this.get("seqId");
  },

  inColumn(rowPos) {
    return true;
  },

  getLength() {
    return 1;
  }
});

var ColumnSelection = Selection.extend({
  defaults: _.extend( {}, Selection.prototype.defaults,
    {type: "column",
    xStart: -1,
    xEnd: -1
  }),

  inRow() {
    return true;
  },

  inColumn(rowPos) {
    return xStart <= rowPos && rowPos <= xEnd;
  },

  getLength() {
    return xEnd - xStart;
  }
});

// pos is a mixin of column and row
// start with Row and only overwrite "inColumn" from Column
var PosSelection = RowSelection.extend(_.extend( {},_.pick(ColumnSelection,"inColumn"),_.pick(ColumnSelection,"getLength"),

  // merge both defaults
  {defaults: _.extend( {}, ColumnSelection.prototype.defaults, RowSelection.prototype.defaults,
    {type: "pos"
  })
}));

module.exports.sel = Selection;
module.exports.possel = PosSelection;
module.exports.rowsel = RowSelection;
module.exports.columnsel = ColumnSelection;
