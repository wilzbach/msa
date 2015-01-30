/* global yourDiv */
var msa = require("biojs-vis-msa");

// set your custom properties
// @see: https://github.com/greenify/biojs-vis-msa/tree/master/src/g

var menuDiv = document.createElement('div');
var msaDiv = document.createElement('div');
yourDiv.appendChild(menuDiv);
yourDiv.appendChild(msaDiv);

var url = "./data/fer1.clustal";
var opts = {
  el: msaDiv
};

opts.conf = {
  dropImport: true // allow to import sequences via drag & drop
};
opts.vis = {
  conserv: false,
  overviewbox: false,
  seqlogo: true,
  metacell: true
};

// init msa
var m = msa(opts);

m.u.file.importURL(url, function() {
  m.g.zoomer.autoHeight(1000); // calcs the height from the sequences (with a cut-off)
  m.render();

  // the menu is independent to the MSA container
  var defMenu = new msa.menu.defaultmenu({
    el: menuDiv,
    msa: m
  });
  defMenu.render();
});

//@biojs-instance=m.g
