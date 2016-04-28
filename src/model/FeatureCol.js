var FeatureCol;
var Feature = require("./Feature");
var Collection = require("backbone-thin").Collection;
var _ = require("underscore");

module.exports = FeatureCol = Collection.extend({
  model: Feature,

  constructor: function() {
    this.startOnCache = [];
    // invalidate cache
    this.on( "all", (function() {
      return this.startOnCache = [];
    }
    ), this
    );
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
    }
    ), false
    );
  },

  getFeatureOnRow: function(row,x) {
    return this.filter(function(el) {
      return el.get("row") === row && el.get("xStart") <= x && x <= el.get("xEnd");
    });
  },

  // tries to auto-fit the rows
  // not a very efficient algorithm
  assignRows: function() {

    var len = (this.max(function(el) { return el.get("xEnd"); })).attributes.xEnd;
    var rows = (() => {
      var result = [];
      for (var x = 0; 0 < len ? x <= len : x >= len; 0 < len ? x++ : x--) {
        result.push(0);
      }
      return result;
    })();

    this.each(function(el) {
      var max = 0;
      var start = el.get("xStart");
      var end = el.get("xEnd");
      for (var x = start; start < end ? x <= end : x >= end; start < end ? x++ : x--) {
        if (rows[x] > max) {
          max = rows[x];
        }
        rows[x]++;
      }
      return el.set("row", max);
    });

    return _.max(rows);
  },

  getCurrentHeight: function() {
    return (this.max(function(el) { return el.get("row"); })).attributes.row + 1;
  },

  // gives the minimal needed number of rows
  // not a very efficient algorithm
  // (there is one in O(n) )
  getMinRows: function() {

    var len = (this.max(function(el) { return el.get("xEnd"); })).attributes.xEnd;
    var rows = ((() => {
      var result = [];
      for (var x = 0; 0 < len ? x <= len : x >= len; 0 < len ? x++ : x--) {
        result.push(0);
      }
      return result;
    })());

    this.each(function(el) {
      return (() => {
        var result = [];
        var start = el.get("xStart");
        var end = el.get("xEnd");
        for (var x = start; start < end ? x <= end : x >= end; start < end ? x++ : x++) {
          result.push(rows[x]++);
        }
        return result;
      })();
    });

    return _.max(rows);
  }
});
