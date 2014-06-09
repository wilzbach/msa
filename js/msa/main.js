define(["./msa","cs!./colorator", "./sequence", "./ordering", "./menu/main",
    "./utils", "./labelcolorator", "./row", "cs!./eventhandler", "./selection/main"], 
    function(Msa,Colorator, Sequence, Ordering, Menu,
      Utils, LabelColorator, Row, Eventhandler, Selection) {
  return {
    msa: Msa,
    colorator: Colorator,
    sequence: Sequence,
    ordering: Ordering,
    menu: Menu,
    utils: Utils,
    labelColorator: LabelColorator,
    row: Row,
    eventhandler: Eventhandler,
    selection: Selection,
  };
});
