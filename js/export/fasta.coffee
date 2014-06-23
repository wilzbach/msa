define ["msa/utils"], (Utils) ->

  class FastaExporter

    @export: (seqs, access) ->
      text = ""
      for seq in seqs
        seq = access(seq) if access?
        #FASTA header
        text += ">#{seq.name}\n"
        # seq
        text += (Utils.splitNChars seq.seq, 80).join "\n"

        text += "\n"
      return text
