import {extend} from "lodash";
import SeqCollection from "../model/SeqCollection";

const TreeHelper =  function(msa) {
  this.msa = msa;
  return this;
};

var tf =

    {loadTree: function(cb) {
      return this.msa.g.package.loadPackages(["msa-tnt", "biojs-io-newick"], cb);
    },

    showTree: function(newickStr) {
      var newick = window.require("biojs-io-newick");
      var mt = window.require("msa-tnt");

      if (typeof newickStr === "string") {
        var newickObj = newick.parse_newick(newickStr);
      } else {
        newickObj = newickStr;
      }

      var sel = new mt.selections();
      var treeDiv;
      if(this.msa.el.childNodes.length === 1){
        treeDiv = document.createElement("div");
        this.msa.el.appendChild(treeDiv);
      } else {
        console.log('A tree already exists. It will be overridden.');
        treeDiv = this.msa.el.childNodes[1];
        treeDiv.innerHTML = '';
      }

      var nodes = mt.app({
        seqs: this.msa.seqs.toJSON(),
        tree: newickObj
      });

      console.log("nodes", nodes.seqs);

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
      nodes.models.forEach((e) => {
        delete e.collection;
        return Object.setPrototypeOf(e, require("backbone-thin").Model.prototype);
      });

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

extend(TreeHelper.prototype , tf);
export default TreeHelper;
