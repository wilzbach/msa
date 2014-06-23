define(["./utils", "cs!./msa","cs!./colorator", "cs!./sequence", "cs!./ordering", "./menu/main",
    "./row", "cs!./eventhandler", "./selection/main" , "cs!./zoombar", "./stage/main", "cs!./feature",
    "cs!./seqmgr"], 
    function(Utils,Msa,Colorator, Sequence, Ordering, Menu,
       Row, Eventhandler, Selection, ZoomBar, stage, Feature, SeqMgr) {
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
    stage: stage,
    feature: Feature,
    seqmgr: SeqMgr,
  };
});
