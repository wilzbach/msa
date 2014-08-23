_ = require "underscore"

# calculate the consensus seq
# TODO: very naive way
module.exports = (seqs) ->

  seqs = seqs.map (el) -> el.get "seq"
  occs = new Array seqs.length

  # count the occurences of the chars of a position
  _.each seqs, (el,i) ->
    _.each el, (char, pos) ->
      occs[pos] = {} unless occs[pos]?
      occs[pos][char] = 0 unless occs[pos][char]?
      occs[pos][char]++

  # now pick the char with most occurences
  _.reduce occs, (memo,occ) ->
    keys = _.keys occ
    memo +=  _.max keys, (key) -> occ[key]
  , ""
