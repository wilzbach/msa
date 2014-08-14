var msa = new biojs.vis.msa.msa(yourDiv);
msa.seqmgr.addDummySequences();

var selList = new biojs.vis.msa.selection.SelectionList();
selList.addSelection(new biojs.vis.msa.selection.VerticalSelection(msa,2));
selList.addSelection(new biojs.vis.msa.selection.HorizontalSelection(msa,3));
