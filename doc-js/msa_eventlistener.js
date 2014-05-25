require(["msa/msa"], function (MSA) {

  var msa = new MSA('msa-eventlistener');
  msa.setConsole('msa-eventlistener-console');

  msa.addDummySequences();
});
