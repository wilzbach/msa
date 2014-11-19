Model = require("backbone-thin").Model
consenus = require "../algo/ConsensusCalc"
_ = require "underscore"

# model for column properties (like their hidden state)
module.exports = Columns = Model.extend

  defaults:
    scaling: "lin" # of the conservation chart e.g. "lin", "exp", "log"

  initialize: ->
    # hidden columns
    @.set "hidden", [] unless @.get("hidden")?

  # assumes hidden columns are sorted
  # @returns n [int] number of hidden columns until n
  calcHiddenColumns: (n) ->
    hidden = @get "hidden"
    newX = n
    for i in hidden
      if i <= newX
        newX++
    newX - n

  # calcs conservation
  _calcConservationPre: (seqs) ->

    # emergency cutoff
    if seqs.length > 1000
      console.log "emergency consenus cutoff", seqs.length
      return

    # calc consensus
    cons = consenus(seqs)
    seqs = seqs.map (el) -> el.get "seq"
    nMax = (_.max seqs, (el) -> el.length).length

    total = new Array nMax
    matches = new Array nMax
    # calc derivation from consenus
    _.each seqs, (el,i) ->
      _.each el, (char, pos) ->
        #if cons[pos] isnt "-" and matches[pos] isnt gap
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

  # counts the occurrences of an amino acid per column
  # TODO: this approach might be a bit slow
  seqLogo: (seqs) ->
    columns = []
    console.log seqs
    for i in [0..seqs.getMaxLength()]
      columns[i] = {}
      seqs.each (el) ->
        seq = el.get "seq"
        seqChar = seq.charAt(i)
        return if seqChar is "-"
        unless columns[i][seqChar]?
          columns[i][seqChar] = 0
        columns[i][seqChar]++
    @.set "seqlogo", columns
    return columns

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
