FastaReader = require("biojs-io-fasta").parse
ClustalReader = require "biojs-io-clustal"

module.exports = FileHelper =
  guessFileType: (name) ->
    name = name.split(".")
    fileName = name[name.length -1]
    switch fileName
      when "aln", "clustal" then return ClustalReader
      when "fasta" then return FastaReader
      else
        return FastaReader

  guessFileFromText: (text) ->
    if text.substring(0,7) is "CLUSTAL"
      return ClustalReader
    else if text.substring(0,1) is ">"
      return FastaReader
    else
      console.warn "Unknown format. Contact greenify"

  parseText: (text) ->
    reader = FileHelper.guessFileFromText text
    seqs = reader.parse text
    return seqs
