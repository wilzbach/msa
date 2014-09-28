Model = require("backbone-thin").Model
consenusCalc = require "../algo/ConsensusCalc"

# simply save the consenus sequences globally
module.exports = Consenus = Model.extend

  defaults:
    consenus : ""

  getConsensus: (seqs) ->
    # emergency cutoff
    if seqs.length > 1000
      return

    cons = consenusCalc(seqs)
    @.set "consenus", cons
    cons
