require(["cs!msa/msa"], function (MSA) {

  var msa = new MSA('msa-zooming');
  msa.columnWidth = 15;
  msa.zoomer.addZoombar();

  msa.seqmgr.addDummySequences();
});
