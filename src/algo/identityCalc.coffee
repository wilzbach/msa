module.exports = identitiyCalc = (seqs, consensus) ->
  seqs.each (seqObj) ->
    seq = seqObj.get "seq"
    matches = 0
    for i in [0..seq.length - 1]
      matches++ if seq[i] is consensus[i]
    seqObj.set "identity", matches / seq.length
