/* global yourDiv */
var msa = require("biojs-vis-msa");
var clustal = require("biojs-io-clustal");

// set your custom properties
// @see: https://github.com/greenify/biojs-vis-msa/tree/master/src/g

var menuDiv = document.createElement('div');
var msaDiv = document.createElement('div');
yourDiv.appendChild(menuDiv);
yourDiv.appendChild(msaDiv);

var url = "./data/fer1.clustal";
clustal.read(url, function(seqs) {
  var opts = {
    el: msaDiv
  };

  opts.conf = {
    url: url, // we tell the MSA viewer about the URL source
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

  m.seqs.reset(seqs);
  m.g.zoomer.autoHeight(1000); // calcs the height from the sequences (with a cut-off)
  m.render();

  // the menu is independent to the MSA container
  var defMenu = new msa.menu.defaultmenu({
    el: menuDiv,
    msa: m
  });
  defMenu.render();

  // BioJS event system test (you can safely remove this in your app)
  //instance=m.g

});
