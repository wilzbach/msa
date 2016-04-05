/* global rootDiv */
var msa = window.msa;
var opts = {
  el: rootDiv,
  importURL: "./data/tree/B2014122194A560KL7I.4.ids.fa",
  bootstrapMenu: true,
};
var m = new msa(opts);
m.importURL("./data/tree/B2014122194A560KL7I.4.ids.phylotree.txt", function(){
  console.log("tree loaded");
});
//@biojs-instance=m.g
