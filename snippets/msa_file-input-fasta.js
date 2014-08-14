var msaDiv = document.createElement(div);
var zoomDiv = document.createElement(div);
yourDiv.append(msaDiv);
yourDiv.append(zoomDiv)
  
// as a async, non-blocking call
Fasta.read("test/dummy/PF00072.fasta", function(seqs) {
  //$("#msa-file-input-fasta-seq").append(seqs.length+ " sequences read");

  // cut the seqs for demo purpose
  seqs.forEach(function(seq){
    seq.name = seq.name.substring(0,20);
  });

  var msa = new biojs.vis.msa.msa(msaDiv,seqs);
  msa.addPlugin(new biojs.vis.msa.zoombar(msa), "0_zoombar");
});
