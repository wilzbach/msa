/* global rootDiv */
var msa = window.msa;

// set your custom properties
// @see: https://github.com/greenify/msa/tree/master/src/g

var menuDiv = document.createElement('div');
var msaDiv = document.createElement('div');
rootDiv.appendChild(menuDiv);
rootDiv.appendChild(msaDiv);

var url = "./data/fer1.clustal";
var opts = {
  el: msaDiv
};

opts.conf = {
  dropImport: true,// allow to import sequences via drag & drop
  manualRendering: true
};
opts.vis = {
  conserv: false,
  overviewbox: false,
  seqlogo: true,
  metacell: true
};
opts.zoomer = {
  labelIdLength: 20
};

// init msa
var m = msa(opts);

gg = m;

m.u.file.importURL(url, function() {
  //m.g.zoomer.autoHeight(1000); // calcs the height from the sequences (with a cut-off)

  // the menu is independent to the MSA container
  var defMenu = new msa.menu.defaultmenu({
    el: menuDiv,
    msa: m
  });
  defMenu.render();
  m.render();
});

//@biojs-instance=m.g
