var seqs = biojs.vis.msa.utils.seqgen.getDummySequences(4,50);
var test = new biojs.vis.msa.msa({seqs: seqs, el: yourDiv});

test.render();

//yourDiv.appendChild(test.el);
