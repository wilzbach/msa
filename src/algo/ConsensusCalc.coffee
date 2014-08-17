_ = require "underscore"

# calculate the consensus seq
# TODO: very naive way
module.exports = (msa) ->

  seqs = msa.seqs.map (el) -> el.get "seq"
  occs = new Array seqs.length

  # count the
  _.each seqs, (el,i) ->
    _.each el, (char, pos) ->
      occs[pos] = {} unless occs[pos]?
      occs[pos][char] = 0 unless occs[pos][char]?
      occs[pos][char]++

  _.reduce occs, (memo,occ) ->
    keys = _.keys occ
    memo +=  _.max keys, (key) -> occ[key]
  , ""
