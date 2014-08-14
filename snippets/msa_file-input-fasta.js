var msaDiv = document.createElement("div");
var zoomDiv = document.createElement("div");
yourDiv.innerHTML = ""; // remove error msg
yourDiv.appendChild(msaDiv);
yourDiv.appendChild(zoomDiv);
  
// as a async, non-blocking call
biojs.io.fasta.parse.read("/test/dummy/samples/p53.clustalo.fasta", function(seqs) {
  //$("#msa-file-input-fasta-seq").append(seqs.length+ " sequences read");

  // cut the seqs for demo purpose
  seqs.forEach(function(seq){
    seq.name = seq.name.substring(0,20);
  });

  var msa = new biojs.vis.msa.msa(msaDiv,seqs);
  msa.addPlugin(new biojs.vis.msa.zoombar(msa), "0_zoombar");
});
