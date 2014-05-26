define(["cs!input/clustal"], function (Clustal) {
  
    // as a async, non-blocking call
    asyncTest( "simple clustal test", function() {
      expect(1);

      Clustal.read("../dummy/samples/p53.clustalo.clustal", function(seqs) {
        equal(34, seqs.length, "invalid seq length");
        start();
      });
    });

    // as a async, non-blocking call
    asyncTest( "simple clustal test2", function() {
      expect(1);

      Clustal.read("../dummy/samples/p53.clustalo.clustal", function(seqs) {
        equal(34, seqs.length, "invalid seq length");
        start();
      });
    });
});
