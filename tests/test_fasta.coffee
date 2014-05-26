define ["cs!input/fasta"], (Fasta) ->
  ->
    module "fasta"
    asyncTest "simple fasta test", ->
      expect 3
      console.log "goo"
      Fasta.read "../dummy/foo.fasta", (seqs) ->
        equal 13, seqs.length, "wrong seq number"
        equal seqs[0].seq[0..59], "MASLITTKAMMSHHHVLSSTRITTLYSDNSIGDQQIKTKPQVPHRLFARRIFGVTRAVIN"
        equal seqs[12].seq, "MKTLLLTLVVVTIVYLDLGYTTKCYNHQSTTPETTEICPDSGYFCYKSSWIDGREGRIERGCTFTCPELTPNGKYVYCCRRDKCNQ"
        start()
