require(["cs!msa/msa", "msa/selection/main"], function (MSA, selection) {

  var msa = new MSA('msa-highlighting');
  msa.setConsole('msa-highlighting-console');
  msa.addDummySequences();

  var selList = new selection.SelectionList();
  selList.addSelection(new selection.VerticalSelection(msa,2));
  selList.addSelection(new selection.HorizontalSelection(msa,3));

});
