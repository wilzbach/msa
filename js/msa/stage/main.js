define(["cs!./seqElement", "cs!./labelElement", "cs!./StageElement",
    "cs!./stage.coffee"], function (seqElement,labelElement,StageElement,stage){
  return {
    stage: stage,
    seqElement: seqElement,
    labelElement: labelElement,
  };
});
