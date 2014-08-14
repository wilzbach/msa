var msa = new biojs.vis.msa.msa(yourDiv);
msa.columnWidth = 15;

msa.seqmgr.addDummySequences();
msa.addPlugin(new biojs.vis.msa.zoombar(msa), "0_zoombar");
