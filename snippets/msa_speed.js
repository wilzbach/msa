// as a async, non-blocking call
biojs.io.fasta.parse.read("http://dev.biojs-msa.org/v1/dummy/external/PF00072_rp15.txt", function(seqs) {
  $("#msa-file-input-fasta-seq").append(seqs.length+ " sequences read");

  // cut the seqs for demo purpose
  //seqs.forEach(function(seq){
  //  seq.name = seq.name.substring(0,20);
  //});

  //seqs = seqs.slice(0,1000);
  var start = new Date().getTime();

  var msa = new biojs.vis.msa.msa('msa-speed',seqs, {speed: true,
    keyevents: true, visibleElements: { ruler: false }});
  
  //msa.addPlugin(new ZoomBar(msa,1,5), "0_zoombar");

  msa.log("Rendering time: " + (new Date().getTime()-start) + " ms");

});
