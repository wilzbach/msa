// as a async, non-blocking call
biojs.io.clustal.read("/test/dummy/samples/p53.clustalo.clustal", function(seqs) {

  // cut the seqs for demo purpose
  /*
     seqs.forEach(function(seq){
     seq.seq = seq.seq.substring(0,50);
     });
     */

  // only display ten seqs
  //seqs = seqs.slice(0,10);

  var msa = new biojs.vis.msa.msa(yourDiv,seqs);
});
