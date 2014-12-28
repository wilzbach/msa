Loader = require "../utils/loader"
Model = require("backbone-thin").Model

module.exports = Package = Model.extend

  initialize: (g) ->
    @g = g

  development:
    "msa-tnt": "/node_modules/msa-tnt/build/bundle.js"
    "biojs-io-newick": "/node_modules/biojs-io-newick/build/biojs-io-newick.min.js"

  # loads a package into the MSA component (if it is not available yet)
  loadPackage: (pkg, cb) ->
    try
      p = require pkg
      cb p
    catch
      Loader.loadScript @_pkgURL(pkg), cb

  # loads multiple packages and calls the cb if all packages are loaded
  loadPackages: (pkgs, cb) ->
      cbs = Loader.joinCb ->
        cb()
      , pkgs.length
      pkgs.forEach (pkg) =>
        @loadPackage pkg, cbs

  # internal method to get the URL for a package
  _pkgURL: (pkg) ->

    if @g.config.get("debug")
      url = @development[pkg]
    else
      url = "http://wzrd.in/bundle/#{pkg}/latest"

    url
