define ["cs!input/generic_reader", "cs!seq"], (GenericReader, Seq) ->
  String::contains = (str) -> -1 isnt this.indexOf str

  class Fasta extends GenericReader

    @parse: (text) ->
      seqs = []
      for line in text.split("\n")
        # check for header
        if line[0] is ">" or line[0] is ";"

          label = line[1..]
          currentSeq = new Seq("", label, seqs.length)
          seqs.push currentSeq

          # extract IDs and push them to the meta dict
          if line.contains "|"
            identifiers = label.split("|")
            k = 1
            while k < identifiers.length
              database = identifiers[k]
              databaseID = identifiers[(k + 1)]
              currentSeq.meta[database] = databaseID
              k += 2
            # assume the last entry is the label
            currentSeq.name = identifiers[identifiers.length - 1]
        else
          currentSeq.seq += line
      return seqs
