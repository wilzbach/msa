define(["./msa","./colorator", "./sequence", "./ordering", "./menu", "./utils", "./labelcolorator", "./row"], function(Msa,Colorator, Sequence, Ordering, Menu, Utils, LabelColorator, Row) {
  return {
    msa: Msa,
    colorator: Colorator,
    sequence: Sequence,
    ordering: Ordering,
    menu: Menu,
    utils: Utils,
    labelColorator: LabelColorator,
    row: Row,
  };
});
