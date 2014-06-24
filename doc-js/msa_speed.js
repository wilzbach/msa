require(["jquery", "cs!input/fasta", "cs!msa/msa","cs!msa/zoombar"], function ($, Fasta, MSA, ZoomBar) {
  
  // as a async, non-blocking call
  Fasta.read("dummy/external/PF00072_rp15.txt", function(seqs) {
    $("#msa-file-input-fasta-seq").append(seqs.length+ " sequences read");

    // cut the seqs for demo purpose
    seqs.forEach(function(seq){
      seq.name = seq.name.substring(0,20);
    });

    //seqs = seqs.slice(0,1000);
    var start = new Date().getTime();

    var msa = new MSA('msa-speed',seqs, {speed: true, visibleElements: { ruler: false }});
    msa.log.setConsole('msa-speed-console');
    //msa.addPlugin(new ZoomBar(msa), "0_zoombar");

    var end = new Date().getTime();
    console.log("Rendering time: " + (end-start) + " ms");

    Node.prototype.countChildNodes = function() {
    return this.hasChildNodes()
      ? Array.prototype.slice.apply(this.childNodes).map(function(el) {
          return 1 + el.countChildNodes();
        }).reduce(function(previousValue, currentValue, index, array){
          return previousValue + currentValue;
        })
      : 0;
      };
    msa.log.log("DOM elements" + document.getElementById("msa-speed").countChildNodes());

  });
});
