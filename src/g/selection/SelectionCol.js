var SelectionManager;
var sel = require("./Selection");
var _ = require("underscore");
var Collection = require("backbone-thin").Collection;

// holds the current user selection
module.exports = SelectionManager = Collection.extend({

  model: sel.sel,

  initialize: function(data, opts) {
    if ((typeof opts !== "undefined" && opts !== null)) {
      this.g = opts.g;

      this.listenTo(this.g, "residue:click", function(e) {
        return this._handleE(e.evt, new sel.possel({
          xStart: e.rowPos,
          xEnd: e.rowPos,
          seqId: e.seqId
        }));
      });

      this.listenTo(this.g, "row:click", function(e) {
        return this._handleE(e.evt, new sel.rowsel({
          seqId: e.seqId
        }));
      });

      return this.listenTo(this.g, "column:click", function(e) {
        return this._handleE(e.evt, new sel.columnsel({
          xStart: e.rowPos,
          xEnd: e.rowPos + e.stepSize - 1
        }));
      });
    }
  },

    //@listenTo @, "add reset", (e) ->
      //@_reduceColumns()

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
     case "column":  return new sel.columnsel(model);
     case "row":  return new sel.rowsel(model);
     case "pos":  return new sel.possel(model);
   }
  },

  // allows normal JSON input
  resetJSON: function(arr) {
    arr = _.map(arr, this._fromJSON);
    return this.reset(arr);
  },

  // @returns array of all selected residues for a row
  getBlocksForRow: function(seqId, maxLen) {
    var selis = this.filter(function(el) { return el.inRow(seqId); });
    var blocks = [];
    for (var i = 0, seli; i < selis.length; i++) {
      seli = selis[i];
      if (seli.attributes.type === "row") {
        blocks = ((function() {
          var result = [];
          var i1 = 0;
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
          var result = [];
          var i1 = seli.attributes.xStart;
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
    var maxLen = conf.maxLen;
    var withPos = conf.withPos;
    var blocks = [];
    if (conf.withPos) {
      var filtered = (this.filter(function(el) { return (el.get('xStart') != null); }) );
    } else {
      filtered = (this.filter(function(el) { return el.get('type') === "column"; }));
    }
    for (var i = 0, seli; i < filtered.length; i++) {
      seli = filtered[i];
      blocks = blocks.concat(((function() {
        var result = [];
        var i1 = seli.attributes.xStart;
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
    blocks = _.uniq(blocks);
    return blocks;
  },

  // inverts the current selection for columns
  // @param rows [Array] all available seqId
  invertRow: function(rows) {
    var selRows = this.where({type:"row"});
    selRows = _.map(selRows, function(el) { return el.attributes.seqId; });
    var inverted = _.filter(rows, function(el) {
      if (selRows.indexOf(el) >= 0) { return false; } // existing selection
      return true;
    });
    // mass insert
    var s = [];
    for (var i = 0, el; i < inverted.length; i++) {
      el = inverted[i];
      s.push(new sel.rowsel({seqId:el}));
    }
    return this.reset(s);
  },

  // inverts the current selection for rows
  // @param rows [Array] all available rows (0..max.length)
  invertCol: function(columns) {
    var xEnd;
    var selColumns = this.where({type:"column"});
    selColumns = _.reduce( selColumns, (function(memo,el) {
      return memo.concat(((function() {
        var result = [];
        var i = el.attributes.xStart;
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
    }
    ), []
    );
    var inverted = _.filter(columns, function(el) {
      if (selColumns.indexOf(el) >= 0) {
        // existing selection
        return false;
      }
      return true;
    });
    // mass insert
    if (inverted.length === 0) { return; }
    var s = [];
    var xStart = xEnd = inverted[0];
    for (var i = 0, el; i < inverted.length; i++) {
      el = inverted[i];
      if (xEnd + 1 === el) {
        // contiguous
        xEnd = el;
      } else {
        // gap between
        s.push(new sel.columnsel({xStart:xStart, xEnd: xEnd}));
        xStart = xEnd = el;
      }
    }
    // check for last gap
    if (xStart !== xEnd) { s.push(new sel.columnsel({xStart:xStart, xEnd: inverted[inverted.length - 1]})); }
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
      var cols = _.filter(arr, function(el) { return el.get('type') === 'column'; });
      var xStart = el.get('xStart');
      var xEnd = el.get('xEnd');

      var lefts = _.filter(cols, function(el) { return el.get('xEnd') === (xStart - 1); });
      for (var i = 0, left; i < lefts.length; i++) {
        left = lefts[i];
        left.set('xEnd', xStart);
      }

      var rights = _.filter(cols, function(el) { return el.get('xStart') === (xEnd + 1); });
      for (var j = 0, right; j < rights.length; j++) {
        right = rights[j];
        right.set('xStart', xEnd);
      }

      if (lefts.length > 0 || rights.length > 0) {
        console.log("removed el");
        return el.collection.remove(el);
      }
    });
  }
});
