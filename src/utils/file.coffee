FastaReader = require("biojs-io-fasta").parse
ClustalReader = require "biojs-io-clustal"
GffReader = require "biojs-io-gff"

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
    unless text?
      console.warn "invalid file format"
      return [, "error"]
    if text.substring(0,7) is "CLUSTAL"
      reader = ClustalReader
      type = "seqs"
    else if text.substring(0,1) is ">"
      reader = FastaReader
      type = "seqs"
    else
      reader = GffReader
      type = "features"
      #console.warn "Unknown format. Contact greenify"
    [reader,type]

  parseText: (text) ->
    [reader, type] = FileHelper.guessFileFromText text
    if type is "seqs"
      seqs = reader.parse text
      return [seqs,type]
    else if type is "features"
      features = reader.parseSeqs text
      return [features,type]
