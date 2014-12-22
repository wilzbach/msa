Loader = require "../utils/loader"
Model = require("backbone-thin").Model

module.exports = Package = Model.extend

  initialize: (g) ->
    @g = g


  development:
    "msa-tnt": "/node_modules/msa-tnt/build/bundle.js"
    "biojs-io-newick": "/node_modules/biojs-io-newick/build/biojs-io-newick.min.js"

  # loads a package into the MSA component
  loadPackage: (pkg, cb) ->
    try
      p = require pkg
      cb p
    catch
      console.log "catched"
      Loader.loadScript @_pkgURL(pkg), cb

  # internal method to get the URL for a package
  _pkgURL: (pkg) ->

    if @g.config.get("debug")
      url = @development[pkg]
    else
      url = "http://wzrd.in/bundle/#{pkg}latest"

    url
