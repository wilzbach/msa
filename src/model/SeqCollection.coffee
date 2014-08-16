Sequence = require "./Sequence"
Collection = require("backbone").Collection

module.exports = SeqManager = Collection.extend
  model: Sequence

  getMaxLength: () ->
    nMax = 0

    @each (seq) ->
      nMax = Math.max nMax, seq.get("seq").length
    return nMax

  getMaxLabelLength: (seqs) ->
    nMax = 0

    if seqs?
      # input array
      for value in seqs
        if value?.name?
          nMax = Math.max nMax, value.name.length
    else
      # internal dict
      seqs = @msa.seqs
      for key,value of seqs
        nMax = Math.max nMax, value.name.length
    return nMax
