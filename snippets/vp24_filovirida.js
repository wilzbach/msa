var opts = {
  el: yourDiv,
  importURL: "./data/VP24_Filoviridae/VP24_Filoviridae-alignment-clustal.aln",
  conf: {
      dropImport: true
  },
  vis: {
      conserv: false,
      overviewbox: true,
      seqlogo: true
  }
};

// init msa
var m = msa(opts);
m.render();

// extend async
m.u.file.importURL("./data/VP24_Filoviridae/VP24_Filoviridae-alignment-annotation.gff");
m.u.file.importURL("./data/VP24_Filoviridae/VP24_Filoviridae-alignment-tree.newick");
