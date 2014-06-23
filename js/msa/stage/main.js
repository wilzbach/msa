define(["cs!./seqElement", "cs!./labelElement", "cs!./StageElement",
    "cs!./stage.coffee", "cs!./FeatureElement"], function (seqElement,labelElement,StageElement,stage, featureElement){
  return {
    stage: stage,
    seqElement: seqElement,
    labelElement: labelElement,
    featureElement: featureElement,
  };
});
