var seqs = biojs.vis.msa.utils.seqgen.getDummySequences(4,50);
var test = new biojs.vis.msa.test2({seqs: seqs, el: yourDiv});

test.render();

//yourDiv.appendChild(test.el);
