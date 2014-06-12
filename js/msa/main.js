define(["./msa","cs!./colorator", "./sequence", "cs!./ordering", "./menu/main",
    "./utils", "./row", "cs!./eventhandler", "./selection/main"], 
    function(Msa,Colorator, Sequence, Ordering, Menu,
      Utils, Row, Eventhandler, Selection) {
  return {
    msa: Msa,
    colorator: Colorator,
    sequence: Sequence,
    ordering: Ordering,
    menu: Menu,
    utils: Utils,
    row: Row,
    eventhandler: Eventhandler,
    selection: Selection,
  };
});
