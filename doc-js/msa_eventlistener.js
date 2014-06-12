require(["cs!msa/msa"], function (MSA) {

  var msa = new MSA('msa-eventlistener', {registerMoveOvers : true});
  msa.setConsole('msa-eventlistener-console');

  msa.addDummySequences();
});
