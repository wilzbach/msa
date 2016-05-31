import {extend, pick} from "lodash";
const Model = require("backbone-thin").Model;

// holds the current user selection
const Selection = Model.extend({
  defaults:
    {type: "super"}
});

const RowSelection = Selection.extend({
  defaults: extend( {}, Selection.prototype.defaults,
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

const ColumnSelection = Selection.extend({
  defaults: extend( {}, Selection.prototype.defaults,
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
const PosSelection = RowSelection.extend(extend( {},
                    pick(ColumnSelection,"inColumn"),
                    pick(ColumnSelection,"getLength"),
  // merge both defaults
  {defaults: extend( {}, ColumnSelection.prototype.defaults, RowSelection.prototype.defaults,
    {type: "pos"
  })
}));

export {Selection as sel};
export {PosSelection as possel};
export {RowSelection as rowsel};
export {ColumnSelection as columnsel};
