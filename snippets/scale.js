/* global rootDiv */
var msa = window.msa;
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
  bootstrapMenu: true, // simplified behavior to add the menu bar, you can also create your own menu instance
  vis: {
    scaleslider: true
  },
  zoomer: {
    columnWidth: 18, // take into account custom columnWidth
  }
};
var m = new msa(opts);
//@biojs-instance=m.g
