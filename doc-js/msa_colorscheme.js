require(["msa/msa"], function (MSA) {

  var msa = new MSA('msa-colorscheme');
  var msa2 = new MSA('msa-colorscheme2');

  // currently only zappo, taylor and hydrophobicity
  msa.colorscheme.setScheme('zappo');
  msa.addDummySequences();

  msa2.colorscheme.setScheme('hydrophobicity');
  msa2.addDummySequences();
});
