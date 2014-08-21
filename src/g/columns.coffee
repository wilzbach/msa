Model = require("backbone").Model
consenus = require "../algo/ConsensusCalc"
_ = require "underscore"

# model for column properties (like their hidden state)
module.exports = Columns = Model.extend

  initialize: ->
    # hidden columns
    @.set "hidden", []

  # calcs conservation
  # (percentage of chars of the consenus seq)
  calcConservation: (seqs) ->
    # calc consensus
    cons = consenus(seqs)
    seqs = seqs.map (el) -> el.get "seq"
    nMax = (_.max seqs, (el) -> el.length).length

    total = new Array nMax
    matches = new Array nMax
    # calc derivation from consenus
    _.each seqs, (el,i) ->
      _.each el, (char, pos) ->
        total[pos] = total[pos] + 1 || 1
        matches[pos] = matches[pos] + 1 || 1 if cons[pos] is char

    for i in [0 .. nMax - 1]
      console.log matches[i] + ",", total[i]
      matches[i] = matches[i] / total[i]

    @.set "conserv", matches
    matches
