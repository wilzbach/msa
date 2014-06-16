define(["./utils", "cs!./msa","cs!./colorator", "./sequence", "cs!./ordering", "./menu/main",
    "./row", "cs!./eventhandler", "./selection/main" , "cs!./zoombar], 
    function(Utils,Msa,Colorator, Sequence, Ordering, Menu,
       Row, Eventhandler, Selection, ZoomBar) {
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
    zoombar: ZoomBar,
  };
});
