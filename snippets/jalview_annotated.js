var opts = {
  el: yourDiv,
  importURL: "./data/jalview/jalview_clustal_msa3.txt",
  conf: {
      dropImport: true
  },
  vis: {
      conserv: false,
      overviewbox: false,
      seqlogo: true
  }
};

// init msa
var m = msa(opts);
m.render();

// add features
msa.io.xhr("./data/jalview/jalview_features_msa3.gff1", function(err, request, body) {
  var features = msa.io.gff.parseSeqs(body);
  m.seqs.addFeatures(features);
  m.render();
});
