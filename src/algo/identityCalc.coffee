module.exports = identitiyCalc = (seqs, consensus) ->
  seqs.each (seqObj) ->
    seq = seqObj.get "seq"
    matches = 0
    total = 0
    for i in [0..seq.length - 1]
      if seq[i] isnt "-" and consensus[i] isnt "-"
        total++
        matches++ if seq[i] is consensus[i]
    seqObj.set "identity", matches / total
