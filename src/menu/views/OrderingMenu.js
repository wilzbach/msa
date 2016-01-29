var OrderingMenu;
var MenuBuilder = require("../menubuilder");
var dom = require("dom-helper");
var _ = require('underscore');

module.exports = OrderingMenu = MenuBuilder.extend({

  initialize: function(data) {
    this.g = data.g;
    this.order = "ID";
    return this.el.style.display = "inline-block";
  },

  setOrder: function(order) {
    this.order = order;
    return this.render();
  },

  // TODO: make more generic
  render: function() {
    this.setName("Sorting");
    this.removeAllNodes();

    var comps = this.getComparators();
    for (var i = 0, m; i < comps.length; i++) {
      m = comps[i];
      this._addNode(m);
    }

    var el = this.buildDOM();

    // TODO: make more efficient
    dom.removeAllChilds(this.el);
    this.el.appendChild(el);
    return this;
  },

  _addNode(m) {
    var text = m.text;
    var style = {};
    if (text === this.order) {
      style.backgroundColor = "#77ED80";
    }
    return this.addNode(text, (() => {
      if ((m.precode != null)) { m.precode(); }
      this.model.comparator = m.comparator;
      this.model.sort();
      return this.setOrder(m.text);
    }
    ), {
        style: style
    });
  },

  getComparators: function() {
    var models = [];


    models.push({text: "ID ↑", comparator: "id"});

    models.push({text: "ID ↓", comparator: function(a, b) {
      // auto converts to string for localeCompare
        return - ("" + a.get("id")).localeCompare("" + b.get("id"), [], {numeric: true} );
    }});

    models.push({text: "Label ↑", comparator: "name"});

    models.push({text: "Label ↓", comparator: function(a, b) {
        return - a.get("name").localeCompare(b.get("name"));
    }});

    models.push({text: "Seq ↑", comparator: "seq"});

    models.push({text: "Seq ↓", comparator: function(a,b) {
        return - a.get("seq").localeCompare(b.get("seq"));
    }});

    var setIdent = () => {
      return this.ident = this.g.stats.identity();
    };

    var setGaps = () => {
      this.gaps = {};
      return this.model.each((el) => {
        var seq = el.attributes.seq;
        return this.gaps[el.id] = (_.reduce(seq, (function(memo, c) { return c === '-' ? ++memo: undefined; }),0))/ seq.length;
      });
    };

    models.push({text: "Identity ↑",comparator: ((a,b) => {
      var val = this.ident[a.id] - this.ident[b.id];
      console.log(this.ident[a.id],this.ident[b.id]);
      if (val > 0) { return 1; }
      if (val < 0) { return -1; }
      return 0;
    }
    ), precode: setIdent});

    models.push({text: "Identity ↓", comparator: ((a,b) => {
      var val = this.ident[a.id] - this.ident[b.id];
      if (val > 0) { return -1; }
      if (val < 0) { return 1; }
      return 0;
    }
    ), precode: setIdent});

    models.push({text: "Gaps ↑", comparator: ((a,b) => {
      var val = this.gaps[a.id] - this.gaps[b.id];
      if (val > 0) { return 1; }
      if (val < 0) { return -1; }
      return 0;
    }
    ), precode: setGaps});

    models.push({text: "Gaps ↓", comparator: ((a,b) => {
      var val = this.gaps[a.id] - this.gaps[b.id];
      if (val < 0) { return 1; }
      if (val > 0) { return -1; }
      return 0;
    }
    ), precode: setGaps});

    models.push({text: "Consensus to top", comparator(seq) {
        return !seq.get("ref");
    }});

    //models.push text: "Partition codes ↑", comparator: "partition", precode: =>
      //# set partitions random
      //@g.vis.set('labelPartition', true)
      //@model.each (el) ->
        //el.set('partition', _.random(1,3))


    return models;
  }
});