FastaReader = require("biojs-io-fasta").parse
ClustalReader = require "biojs-io-clustal"
GffReader = require "biojs-io-gff"
_ = require "underscore"

module.exports = FileHelper = (msa) ->
  @msa = msa
  @

funs =
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
      return ["", "error"]
    if text.substring(0,7) is "CLUSTAL"
      reader = ClustalReader
      type = "seqs"
    else if text.substring(0,1) is ">"
      reader = FastaReader
      type = "seqs"
    else if text.substring(0,1) is "("
      type = "newick"
    else
      reader = GffReader
      type = "features"
      #console.warn "Unknown format. Contact greenify"
    [reader,type]

  parseText: (text) ->
    [reader, type] = @guessFileFromText text
    if type is "seqs"
      seqs = reader.parse text
      return [seqs,type]
    else if type is "features"
      features = reader.parseSeqs text
      return [features,type]
    else
      return [text,type]

  importFiles: (files) ->
    for i in [0..files.length - 1] by 1
      file = files[i]
      reader = new FileReader()
      reader.onload = (evt) =>
        @importFile evt.target.result
      reader.readAsText file

  importFile: (file) ->
    [objs, type] = @parseText file
    if type is "error"
        return "error"
    if type is "seqs"
      @msa.seqs.reset objs
      @msa.g.config.set "url", "userimport"
      @msa.g.trigger "url:userImport"
    else if type is "features"
      @msa.seqs.addFeatures objs
    else if type is "newick"
      @msa.u.tree.loadTree =>
        @msa.u.tree.showTree file

    fileName = file.name

_.extend FileHelper::, funs
