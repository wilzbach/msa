_ = require "underscore"

module.exports = treeHelper =  (msa) ->
  @msa = msa
  @

treeHelperFun =

    loadTree: (cb) ->
      @msa.g.package.loadPackages ["msa-tnt", "biojs-io-newick"], cb

    showTree: (newickStr) ->
      newick = require "biojs-io-newick"
      if typeof newickStr is "string"
        newickObj = newick.parse_newick newickStr
      else
        newickObj = newickStr

      mt = require("msa-tnt")

      sel = new mt.selections()
      treeDiv = document.createElement "div"
      document.body.appendChild treeDiv

      console.log seqs
      console.log tree

      nodes = mt.app
        seqs: @msa.seqs.models
        tree: newickObj

      console.log "nodes", nodes

      t = new mt.adapters.tree
        model: nodes,
        el: treeDiv,
        sel: sel,

      treeDiv.style.width = "500px"

_.extend treeHelper:: , treeHelperFun
