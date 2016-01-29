var treeHelper;
var _ = require("underscore");
var SeqCollection = require("../model/SeqCollection");

module.exports = treeHelper =  function(msa) {
  this.msa = msa;
  return this;
};

var tf =

    {loadTree: function(cb) {
      return this.msa.g.package.loadPackages(["msa-tnt", "biojs-io-newick"], cb);
    },

    showTree: function(newickStr) {
      var newick = this.require("biojs-io-newick");
      if (typeof newickStr === "string") {
        var newickObj = newick.parse_newick(newickStr);
      } else {
        newickObj = newickStr;
      }

      var mt = this.require("msa-tnt");

      var sel = new mt.selections();
      var treeDiv = document.createElement("div");
    //   @msa.el.insertBefore treeDiv, @msa.el.childNodes[0]
      this.msa.el.appendChild(treeDiv);

      console.log(this.msa.seqs.models);
      console.log(newickObj);

      var nodes = mt.app({
        seqs: this.msa.seqs.toJSON(),
        tree: newickObj
      });

      console.log("nodes", nodes);

      var t = new mt.adapters.tree({
        model: nodes,
        el: treeDiv,
        sel: sel
      });

      //treeDiv.style.width = "500px"

      // construct msa in a virtual dom
      var m = new mt.adapters.msa({
          model: nodes,
          sel: sel,
          msa: this.msa
      });

      // remove top collection
      _.each(nodes.models, function(e) {
        delete e.collection;
        return Object.setPrototypeOf(e, require("backbone-thin").Model.prototype);
      }
      );

      this.msa.seqs.reset(nodes.models);
      //@msa.draw()
      //@msa.render()
      return console.log(this.msa.seqs);
    },

    // workaround against browserify's static analysis
    require(pkg) {
      return require(pkg);
    }
    };

_.extend(treeHelper.prototype , tf);