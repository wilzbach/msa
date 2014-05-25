require(["jquery", "cs!input/fasta", "msa/msa"], function ($, Fasta, MSA) {
  
  // as a async, non-blocking call
  Fasta.read("dummy/foo.fasta", function(seqs) {
    $("#msa-file-input-fasta-seq").append(seqs.length+ " sequences read");

    // cut the seqs for demo purpose
    seqs.forEach(function(seq){
      seq.seq = seq.seq.substring(0,50);
    });

    var msa = new MSA('msa-file-input-fasta');
    msa.seqOffset = 1000;
    msa.addSequences(seqs);
  });
});
