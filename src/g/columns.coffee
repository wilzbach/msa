Model = require("backbone").Model
consenus = require "../algo/ConsensusCalc"
_ = require "underscore"

# model for column properties (like their hidden state)
module.exports = Columns = Model.extend

  defaults:
    scaling: "lin"

  initialize: ->
    # hidden columns
    @.set "hidden", []

  # calcs conservation
  _calcConservationPre: (seqs) ->
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
    [matches, total, nMax]

  calcConservation: (seqs) ->
    if @attributes.scaling is "exp"
      return @calcConservationExp seqs
    else if @attributes.scaling is "log"
      return @calcConservationLog seqs
    else if @attributes.scaling is "lin"
      return @calcConservationLin seqs

  # (percentage of chars of the consenus seq)
  calcConservationLin: (seqs) ->
    [matches,total, nMax] = @_calcConservationPre seqs
    for i in [0 .. nMax - 1]
      matches[i] = matches[i] / total[i]
    @.set "conserv", matches
    matches

  # (percentage of chars of the consenus seq)
  calcConservationLog: (seqs) ->
    [matches,total, nMax] = @_calcConservationPre seqs
    for i in [0 .. nMax - 1]
      matches[i] = Math.log(matches[i] + 1) / Math.log(total[i] + 1)
    @.set "conserv", matches
    matches

  calcConservationExp: (seqs) ->
    [matches,total, nMax] = @_calcConservationPre seqs
    for i in [0 .. nMax - 1]
      matches[i] = Math.exp(matches[i] + 1) / Math.exp(total[i] + 1)
    @.set "conserv", matches
    matches
