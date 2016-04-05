/* global rootDiv */
var msa = window.msa;
var opts = {
  el: rootDiv,
  importURL: "./data/fer1.clustal",
  bootstrapMenu: true, // simplified behavior to add the menu bar, you can also create your own menu instance
};
var m = new msa(opts);
//@biojs-instance=m.g
