_ = require "underscore"
SeqCollection = require "../model/SeqCollection"

module.exports = treeHelper =  (msa) ->
  @msa = msa
  @

tf =

    loadTree: (cb) ->
      @msa.g.package.loadPackages ["msa-tnt", "biojs-io-newick"], cb

    showTree: (newickStr) ->
      newick = @require "biojs-io-newick"
      if typeof newickStr is "string"
        newickObj = newick.parse_newick newickStr
      else
        newickObj = newickStr

      mt = @require "msa-tnt"

      sel = new mt.selections()
      treeDiv = document.createElement "div"
      @msa.el.insertBefore treeDiv, @msa.el.childNodes[0]

      console.log @msa.seqs.models
      console.log newickObj

      nodes = mt.app
        seqs: @msa.seqs.toJSON()
        tree: newickObj

      console.log "nodes", nodes

      t = new mt.adapters.tree
        model: nodes,
        el: treeDiv,
        sel: sel,

      #treeDiv.style.width = "500px"

      # construct msa in a virtual dom
      m = new mt.adapters.msa
        model: nodes,
        sel: sel,
        msa: @msa

      # remove top collection
      _.each(nodes.models, (e) ->
        delete e.collection
        Object.setPrototypeOf(e, require("backbone-thin").Model::)
      )

      @msa.seqs.reset(nodes.models)
      #@msa.draw()
      #@msa.render()
      console.log @msa.seqs

    # workaround against browserify's static analysis
    require: (pkg) ->
      require pkg

_.extend treeHelper:: , tf
