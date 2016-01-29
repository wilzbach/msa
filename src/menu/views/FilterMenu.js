var FilterMenu;
var MenuBuilder = require("../menubuilder");
var _ = require("underscore");

module.exports = FilterMenu = MenuBuilder.extend({

  initialize: function(data) {
    this.g = data.g;
    return this.el.style.display = "inline-block";
  },

  render: function() {
    this.setName("Filter");
    this.addNode("Hide columns by threshold",(e) => {
      var threshold = prompt("Enter threshold (in percent)", 20);
      threshold = threshold / 100;
      var maxLen = this.model.getMaxLength();
      var hidden = [];
      // TODO: cache this value
      var conserv = this.g.stats.scale(this.g.stats.conservation());
      var end = maxLen - 1;
      for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
        if (conserv[i] < threshold) {
          hidden.push(i);
        }
      }
      return this.g.columns.set("hidden", hidden);
    });

    this.addNode("Hide columns by selection", () => {
      var hiddenOld = this.g.columns.get("hidden");
      var hidden = hiddenOld.concat(this.g.selcol.getAllColumnBlocks({maxLen: this.model.getMaxLength(), withPos: true}));
      this.g.selcol.reset([]);
      return this.g.columns.set("hidden", hidden);
    });

    this.addNode("Hide columns by gaps", () => {
      var threshold = prompt("Enter threshold (in percent)", 20);
      threshold = threshold / 100;
      var maxLen = this.model.getMaxLength();
      var hidden = [];
      var end = maxLen - 1;
      for (var i = 0; 0 < end ? i <= end : i >= end; 0 < end ? i++ : i--) {
        var gaps = 0;
        var total = 0;
        this.model.each(function(el) {
          if (el.get('seq')[i] === "-") { gaps++; }
          return total++;
        });
        var gapContent = gaps / total;
        if (gapContent > threshold) {
          hidden.push(i);
        }
      }
      return this.g.columns.set("hidden", hidden);
    });

    this.addNode("Hide seqs by identity", () => {
      var threshold = prompt("Enter threshold (in percent)", 20);
      threshold = threshold / 100;
      return this.model.each(function(el) {
        if (el.get('identity') < threshold) {
          return el.set('hidden', true);
        }
      });
    });

    this.addNode("Hide seqs by selection", () => {
      var hidden = this.g.selcol.where({type: "row"});
      var ids = _.map(hidden, function(el) { return el.get('seqId'); });
      this.g.selcol.reset([]);
      return this.model.each(function(el) {
        if (ids.indexOf(el.get('id')) >= 0) {
          return el.set('hidden', true);
        }
      });
    });

    this.addNode("Hide seqs by gaps", () => {
      var threshold = prompt("Enter threshold (in percent)", 40);
      return this.model.each(function(el,i) {
        var seq = el.get('seq');
        var gaps = _.reduce(seq, (function(memo, c) { return c === '-' ? ++memo: undefined; }),0);
        if (gaps >  threshold) {
          return el.set('hidden', true);
        }
      });
    });

    this.addNode("Reset", () => {
      this.g.columns.set("hidden", []);
      return this.model.each(function(el) {
        if (el.get('hidden')) {
          return el.set('hidden', false);
        }
      });
    });

    this.el.appendChild(this.buildDOM());
    return this;
  }
});
