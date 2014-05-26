define(["./msa","./colorator", "./sequence", "./ordering", "./menu", "./utils", "./labelcolorator", "./row", "cs!./highlightor", "cs!./eventhandler"], function(Msa,Colorator, Sequence, Ordering, Menu, Utils, LabelColorator, Row, Highlightor, Eventhandler) {
  return {
    msa: Msa,
    colorator: Colorator,
    sequence: Sequence,
    ordering: Ordering,
    menu: Menu,
    utils: Utils,
    labelColorator: LabelColorator,
    row: Row,
    highlightor: Highlightor,
    eventhandler: Eventhandler,
  };
});
