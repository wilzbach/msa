Model = require("backbone").Model
consenusCalc = require "../algo/ConsensusCalc"

# simply save the consenus sequences globally
module.exports = Consenus = Model.extend

  defaults:
    consenus : ""

  getConsensus: (seqs) ->
    cons = consenusCalc(seqs)
    @.set "consenus", cons
    cons
