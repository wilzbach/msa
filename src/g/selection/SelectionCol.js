import {sel, possel, rowsel, columnsel} from "./Selection";
import {uniq, filter} from "lodash";
const Collection = require("backbone-thin").Collection;

// holds the current user selection
const SelectionManager = Collection.extend({

  model: sel,

  initialize: function(data, opts) {
    if ((typeof opts !== "undefined" && opts !== null)) {
      this.g = opts.g;

      this.listenTo(this.g, "residue:click", function(e) {
        return this._handleE(e.evt, new possel({
          xStart: e.rowPos,
          xEnd: e.rowPos,
          seqId: e.seqId
        }));
      });

      this.listenTo(this.g, "row:click", function(e) {
        return this._handleE(e.evt, new rowsel({
          seqId: e.seqId
        }));
      });

      return this.listenTo(this.g, "column:click", function(e) {
        return this._handleE(e.evt, new columnsel({
          xStart: e.rowPos,
          xEnd: e.rowPos + e.stepSize - 1
        }));
      });
    }
  },

  getSelForRow: function(seqId) {
    return this.filter(function(el) { return el.inRow(seqId); });
  },

  getSelForColumns: function(rowPos) {
    return this.filter(function(el) { return el.inColumn(rowPos); });
  },

  addJSON: function(model) {
    return this.add(this._fromJSON(model));
  },

  _fromJSON: function(model) {
   switch (model.type) {
     case "column":  return new columnsel(model);
     case "row":  return new rowsel(model);
     case "pos":  return new possel(model);
   }
  },

  // allows normal JSON input
  resetJSON: function(arr) {
    arr = arr.map(this._fromJSON);
    return this.reset(arr);
  },

  // @returns array of all selected residues for a row
  getBlocksForRow: function(seqId, maxLen) {
    const selis = this.filter(function(el) { return el.inRow(seqId); });
    let blocks = [];
    for (let i = 0, seli; i < selis.length; i++) {
      let seli = selis[i];
      if (seli.attributes.type === "row") {
        blocks = ((function() {
          const result = [];
          let i1 = 0;
          if (0 <= maxLen) {
            while (i1 <= maxLen) {
              result.push(i1++);
            }
          } else {
            while (i1 >= maxLen) {
              result.push(i1--);
            }
          }
          return result;
        })());
        break;
      } else {
        blocks = blocks.concat(((function() {
          const result = [];
          let i1 = seli.attributes.xStart;
          if (seli.attributes.xStart <= seli.attributes.xEnd) {
            while (i1 <= seli.attributes.xEnd) {
              result.push(i1++);
            }
          } else {
            while (i1 >= seli.attributes.xEnd) {
              result.push(i1--);
            }
          }
          return result;
        })()));
      }
    }
    return blocks;
  },

  // @returns array with all columns being selected
  // example: 0-4... 12-14 selected -> [0,1,2,3,4,12,13,14]
  getAllColumnBlocks: function(conf) {
    const maxLen = conf.maxLen;
    const withPos = conf.withPos;
    let blocks = [];
    let filtered;
    if (conf.withPos) {
      filtered = (this.filter(function(el) { return (el.get('xStart') != null); }) );
    } else {
      filtered = (this.filter(function(el) { return el.get('type') === "column"; }));
    }
    for (let i = 0, seli; i < filtered.length; i++) {
      let seli = filtered[i];
      blocks = blocks.concat(((function() {
        const result = [];
        let i1 = seli.attributes.xStart;
        if (seli.attributes.xStart <= seli.attributes.xEnd) {
          while (i1 <= seli.attributes.xEnd) {
            result.push(i1++);
          }
        } else {
          while (i1 >= seli.attributes.xEnd) {
            result.push(i1--);
          }
        }
        return result;
      })()));
    }
    blocks = uniq(blocks);
    return blocks;
  },

  // inverts the current selection for columns
  // @param rows [Array] all available seqId
  invertRow: function(rows) {
    let selRows = this.where({type:"row"});
    selRows = selRows.map((el) => el.attributes.seqId);
    const inverted = filter(rows, function(el) {
      if (selRows.indexOf(el) >= 0) { return false; } // existing selection
      return true;
    });
    // mass insert
    const s = [];
    for (let i = 0, el; i < inverted.length; i++) {
      let el = inverted[i];
      s.push(new rowsel({seqId:el}));
    }
    return this.reset(s);
  },

  // inverts the current selection for rows
  // @param rows [Array] all available rows (0..max.length)
  invertCol: function(columns) {
    const selColumns = this.where({type:"column"}).reduce((memo,el) => {
      return memo.concat(((() => {
        const result = [];
        let i = el.attributes.xStart;
        if (el.attributes.xStart <= el.attributes.xEnd) {
          while (i <= el.attributes.xEnd) {
            result.push(i++);
          }
        } else {
          while (i >= el.attributes.xEnd) {
            result.push(i--);
          }
        }
        return result;
      })()));
    }, []);
    const inverted = filter(columns, (el) => {
      if (selColumns.indexOf(el) >= 0) {
        // existing selection
        return false;
      }
      return true;
    });
    // mass insert
    if (inverted.length === 0) { return; }
    const s = [];
    let xStart = inverted[0];
    let xEnd = xStart;
    for (let i = 0, el; i < inverted.length; i++) {
      el = inverted[i];
      if (xEnd + 1 === el) {
        // contiguous
        xEnd = el;
      } else {
        // gap between
        s.push(new columnsel({xStart:xStart, xEnd: xEnd}));
        xStart = xEnd = el;
      }
    }
    // check for last gap
    if (xStart !== xEnd) { s.push(new columnsel({xStart:xStart, xEnd: inverted[inverted.length - 1]})); }
    return this.reset(s);
  },

  // method to decide whether to start a new selection
  // or append to the old one (depending whether CTRL was pressed)
  _handleE: function(e, selection) {
    if (e.ctrlKey || e.metaKey) {
      return this.add(selection);
    } else {
      return this.reset([selection]);
    }
  },

  // experimental reduce method for columns
  _reduceColumns: function() {
    return this.each(function(el, index, arr) {
      const cols = filter(arr, (el) => el.get('type') === 'column');
      const xStart = el.get('xStart');
      const xEnd = el.get('xEnd');

      const lefts = filter(cols, (el) => el.get('xEnd') === (xStart - 1));
      for (let i = 0, left; i < lefts.length; i++) {
        let left = lefts[i];
        left.set('xEnd', xStart);
      }

      const rights = filter(cols, (el) =>  el.get('xStart') === (xEnd + 1));
      for (let j = 0, right; j < rights.length; j++) {
        let right = rights[j];
        right.set('xStart', xEnd);
      }

      if (lefts.length > 0 || rights.length > 0) {
        console.log("removed el");
        return el.collection.remove(el);
      }
    });
  }
});
export default SelectionManager;
