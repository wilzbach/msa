Model = require("backbone").Model
consenusCalc = require "../algo/ConsensusCalc"

# this is an example of how one could color the MSA
# feel free to create your own color scheme
module.exports = Consenus = Model.extend

  defaults:
    consenus : ""

  getConsensus: (seqs) ->
    cons = consenusCalc(seqs)
    @.set "consenus", cons
    cons
