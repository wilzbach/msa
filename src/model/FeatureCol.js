const Collection = require("backbone-thin").Collection;
import {max} from "lodash";

import Feature from "./Feature";

const FeatureCol = Collection.extend({
  model: Feature,

  constructor: function() {
    this.startOnCache = [];
    // invalidate cache
    this.on( "all", (function() {
      return this.startOnCache = [];
    }), this);
    return Collection.apply(this, arguments);
  },

  // returns all features starting on index
  startOn: function(index) {
    if (!(this.startOnCache[index] != null)) {
      this.startOnCache[index] = this.where({xStart: index});
    }
    return this.startOnCache[index];
  },

  contains: function(index) {
    return this.reduce( (function(el,memo) {
      return memo || el.contains(index);
    }), false);
  },

  getFeatureOnRow: function(row,x) {
    return this.filter(function(el) {
      return el.get("row") === row && el.get("xStart") <= x && x <= el.get("xEnd");
    });
  },

  // tries to auto-fit the rows
  // not a very efficient algorithm
  assignRows: function() {

    const len = (this.max(function(el) { return el.get("xEnd"); })).attributes.xEnd;
    const rows = (() => {
      const result = [];
      for (let x = 0; 0 < len ? x <= len : x >= len; 0 < len ? x++ : x--) {
        result.push(0);
      }
      return result;
    })();

    this.each(function(el) {
      let max = 0;
      const start = el.get("xStart");
      const end = el.get("xEnd");
      for (let x = start; start < end ? x <= end : x >= end; start < end ? x++ : x--) {
        if (rows[x] > max) {
          max = rows[x];
        }
        rows[x]++;
      }
      return el.set("row", max);
    });

    return max(rows);
  },

  getCurrentHeight: function() {
    return (this.max(function(el) { return el.get("row"); })).attributes.row + 1;
  },

  // gives the minimal needed number of rows
  // not a very efficient algorithm
  // (there is one in O(n) )
  getMinRows: function() {

    const len = (this.max(function(el) { return el.get("xEnd"); })).attributes.xEnd;
    const rows = ((() => {
      const result = [];
      for (let x = 0; 0 < len ? x <= len : x >= len; 0 < len ? x++ : x--) {
        result.push(0);
      }
      return result;
    })());

    this.each(function(el) {
      return (() => {
        const result = [];
        const start = el.get("xStart");
        const end = el.get("xEnd");
        for (let x = start; start < end ? x <= end : x >= end; start < end ? x++ : x++) {
          result.push(rows[x]++);
        }
        return result;
      })();
    });

    return max(rows);
  }
});
export default FeatureCol;
