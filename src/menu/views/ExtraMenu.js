var ExtraMenu;
var MenuBuilder = require("../menubuilder");
var Seq = require("../../model/Sequence");
var Loader = require("../../utils/loader");
var xhr = require("xhr");

module.exports = ExtraMenu = MenuBuilder.extend({

  initialize: function(data) {
    this.g = data.g;
    this.el.style.display = "inline-block";
    return this.msa = data.msa;
  },

  render: function() {
    this.setName("Extras");
    var stats = this.g.stats;
    var msa = this.msa;
    this.addNode("Add consensus seq", () => {
      var con = stats.consensus();
      var seq = new Seq({
        seq: con,
        id: "0c",
        name: "Consenus"
      });
      this.model.add(seq);
      this.model.setRef(seq);
      this.model.comparator = function(seq) {
        return !seq.get("ref");
      };
      return this.model.sort();
    });

    // @addNode "Calc Tree", ->
    //   # this is a very experimental feature
    //   # TODO: exclude msa & tnt in the adapter package
    //   newickStr = ""
    //
    //   cbs = Loader.joinCb ->
    //     msa.u.tree.showTree nwkData
    //   , 2, @
    //
    //   msa.u.tree.loadTree cbs
    //   # load fake tree
    //   nwkData =
    //     name: "root",
    //     children: [
    //       name: "c1",
    //       branch_length: 4
    //       children: msa.seqs.filter (f,i) ->  i % 2 is 0
    //     ,
    //       name: "c2",
    //       children: msa.seqs.filter (f,i) ->  i % 2 is 1
    //       branch_length: 4
    //     ]
    //   msa.seqs.each (s) ->
    //     s.set "branch_length", 2
    //   cbs()

    this.addNode("Increase font size", () => {
      var columnWidth =  this.g.zoomer.get("columnWidth");
      var nColumnWidth = columnWidth + 5;
      this.g.zoomer.set("columnWidth",  nColumnWidth);
      this.g.zoomer.set("rowHeight", nColumnWidth);
      var nFontSize = nColumnWidth * 0.7;
      this.g.zoomer.set("residueFont", nFontSize);
      return this.g.zoomer.set("labelFontSize",  nFontSize);
    });
    this.addNode("Decrease font size", () => {
      var columnWidth =  this.g.zoomer.get("columnWidth");
      var nColumnWidth = columnWidth - 2;
      this.g.zoomer.set("columnWidth",  nColumnWidth);
      this.g.zoomer.set("rowHeight", nColumnWidth);
      var nFontSize = nColumnWidth * 0.6;
      this.g.zoomer.set("residueFont", nFontSize);
      this.g.zoomer.set("labelFontSize",  nFontSize);

      if (this.g.zoomer.get("columnWidth") < 8) {
        return this.g.zoomer.set("textVisible", false);
      }
    });


    this.addNode("Jump to a column", () => {
      var offset = prompt("Column", "20");
      if (offset < 0 || offset > this.model.getMaxLength() || isNaN(offset)) {
        alert("invalid column");
        return;
      }
      return this.g.zoomer.setLeftOffset(offset);
    });

    this.el.appendChild(this.buildDOM());
    return this;
  }
});
