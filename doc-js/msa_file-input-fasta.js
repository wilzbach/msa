require(["jquery", "cs!input/fasta", "cs!msa/msa"], function ($, Fasta, MSA) {
  
  // as a async, non-blocking call
  Fasta.read("dummy/samples/p53.fasta", function(seqs) {
    $("#msa-file-input-fasta-seq").append(seqs.length+ " sequences read");

    // cut the seqs for demo purpose
    seqs.forEach(function(seq){
      seq.name = seq.name.substring(0,50);
    });

    var msa = new MSA('msa-file-input-fasta',seqs);
  });
});
