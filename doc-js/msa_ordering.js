require(["cs!msa/msa", "msa/sequence"], function (MSA, Sequence) {

  var msa = new MSA('msa-ordering');
  msa.setConsole('msa-ordering-console');

  // define seqs
  var seqs = [new Sequence("MSPFTACAPDRLNAGECTF", "awesome name", 1)
         ,new Sequence("QQTSPLQQQDILDMTVYCD", "awesome name2", 2)
         ,new Sequence("FTQHGMSGHEISPPSEPGH", "awesome name3", 3)];

  msa.addSequences(seqs);
  msa.orderSeqs([2,3,1]);
});
