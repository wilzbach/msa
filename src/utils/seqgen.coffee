Sequence = require("biojs-model").seq
BMath = require "./bmath"
Stat = require "stat.seqs"

seqgen = module.exports =
  _generateSequence: (len) ->
    text = ""
    for i in [0..len - 1] by 1
      text += seqgen.getRandomChar()
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

  getRandomChar: (dict) ->
    possible = dict || "ABCDEFGHIJKLMNOPQRSTUVWXYZ"
    possible.charAt Math.floor(Math.random() * possible.length)

  # generates a dummy sequences
  # @param len [int] number of generated sequences
  # @param seqLen [int] length of the generated sequences
  genConservedSequences: (len, seqLen, dict) ->
    seqs = []
    len = BMath.getRandomInt 3,5 unless len?
    seqLen = BMath.getRandomInt 50,200 unless seqLen?

    dict = dict || "ACDEFGHIKLMNPQRSTVWY---"

    for i in [1..len] by 1
      seqs[i-1] = ""

    tolerance = 0.2

    conservAim = 1
    for i in [0.. seqLen - 1] by 1
      if i % 3 == 0
        conservAim = (BMath.getRandomInt 50,100) / 100
      observed = []
      for j in [0..len - 1] by 1
        counter = 0
        while counter < 100
          c = seqgen.getRandomChar dict
          cConserv = Stat observed
          cConserv.addSeq c
          counter++
          if Math.abs(conservAim - cConserv.scale(cConserv.conservation())[0]) < tolerance
            break
        seqs[j] += c
        observed.push c

    pseqs = []
    for i in [1..len] by 1
      pseqs.push new Sequence(seqs[i-1], "seq" + i, "r" + i)

    return pseqs
