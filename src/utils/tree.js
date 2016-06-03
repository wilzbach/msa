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

      if(this.msa.el.getElementsByClassName('tnt_groupDiv').length === 0){
        treeDiv = document.createElement("div");
        this.msa.el.appendChild(treeDiv);
      } else {
        console.log('A tree already exists. It will be overridden.');
        treeDiv = this.msa.el.getElementsByClassName('tnt_groupDiv')[0].parentNode;
        treeDiv.innerHTML = '';
      }

      const seqs = this.msa.seqs.toJSON();
      //adapt tree ids to sequence ids
      function iterateTree(nwck){
        if(nwck.children != null){
          nwck.children.forEach(x => iterateTree(x));
        } else {
          //found a leave
          let seq = seqs.filter(s => s.name === nwck.name)[0];

          if(seq != null){
            if(typeof seq.id === 'number'){
              //no tree has been uploaded so far, seqs have standard IDs
              seq.ids = [`s${seq.id + 1}`];
              nwck.name = `s${seq.id + 1}`;
            } else {
              //seqs have custom ids - don't mess with these
              nwck.name = seq.id;
            }
          }
        }
      }
      iterateTree(newickObj);

      var nodes = mt.app({
        seqs: seqs,
        tree: newickObj
      });

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
