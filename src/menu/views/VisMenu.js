var VisMenu;
var MenuBuilder = require("../menubuilder");
var dom = require("dom-helper");

module.exports = VisMenu = MenuBuilder.extend({

  initialize: function(data) {
    this.g = data.g;
    this.el.style.display = "inline-block";
    return this.listenTo(this.g.vis, "change", this.render);
  },

  render: function() {
    this.removeAllNodes();
    this.setName("Vis.elements");

    var visElements = this.getVisElements();
    for (var i = 0, visEl; i < visElements.length; i++) {
      visEl = visElements[i];
      this._addVisEl(visEl);
    }

    // other
    this.addNode("Reset", () => {
      this.g.vis.set("labels", true);
      this.g.vis.set("sequences", true);
      this.g.vis.set("metacell", true);
      this.g.vis.set("conserv", true);
      this.g.vis.set("labelId", true);
      this.g.vis.set("labelName", true);
      this.g.vis.set("labelCheckbox", false);
      this.g.vis.set("seqlogo", false);
      this.g.vis.set("gapHeader", false);
      this.g.vis.set("leftHeader", true);
      this.g.vis.set("metaGaps", true);
      this.g.vis.set("metaIdentity", true);
      return this.g.vis.set("metaLinks", true);
    });

    // TODO: make more efficient
    dom.removeAllChilds(this.el);
    this.el.appendChild(this.buildDOM());
    return this;
  },

  _addVisEl(visEl) {
    var style = {};

    if (this.g.vis.get(visEl.id)) {
      var pre = "Hide ";
      style.color = "red";
    } else {
      pre = "Show ";
      style.color = "green";
    }

    return this.addNode( (pre + visEl.name), (() => {
      return this.g.vis.set(visEl.id, ! this.g.vis.get(visEl.id));
    }
    ),
      {style: style
    });
  },

  getVisElements: function() {
    var vis = [];
    vis.push({name: "residues indices", id: "markers"});
    vis.push({name: "ID/Label", id: "labels"});
    //vis.push name: "Sequences", id: "sequences"
    vis.push({name: "meta info (Gaps/Ident)", id: "metacell"});
    vis.push({name: "overview panel", id: "overviewbox"});
    vis.push({name: "sequence logo", id: "seqlogo"});
    vis.push({name: "gap weights", id: "gapHeader"});
    vis.push({name: "conservation weights", id: "conserv"});
    //vis.push name: "Left header", id: "leftHeader"
    vis.push({name: "Label", id: "labelName"});
    vis.push({name: "ID", id: "labelId"});
    //vis.push name: "Label checkbox", id: "labelCheckbox"
    vis.push({name: "gaps %", id: "metaGaps"});
    vis.push({name: "identity score", id: "metaIdentity"});
    // vis.push name: "Meta links", id: "metaLinks"
    return vis;
  }
});
