Sequence = require("biojs-model").seq
BMath = require "./bmath"

seqgen = module.exports =
  _generateSequence: (len) ->
    text = ""
    possible = "ABCDEFGHIJKLMNOPQRSTUVWXYZabcdefghijklmnopqrstuvwxyz"

    for i in [0..len - 1] by 1
      text += possible.charAt Math.floor(Math.random() * possible.length)
    return text

  # generates a dummy sequences
  # @param len [int] number of generated sequences
  # @param seqLen [int] length of the generated sequences
  getDummySequences: (len, seqLen) ->
    seqs = []
    len = BMath.getRandomInt 3,5 unless len?
    seqLen = BMath.getRandomInt 50,200 unless seqLen?

    for i in [1..len] by 1
      seqs.push new Sequence(seqgen._generateSequence(seqLen), "seq" + i,
      "r" + i)
    return seqs
