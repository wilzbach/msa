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
    dropImport: true
  };
  opts.vis = {
    conserv: false,
    overviewbox: false,
    seqlogo: true
  };
  opts.zoomer = {
    alignmentHeight: 225,
    labelWidth: 130,
    labelFontsize: "13px",
    labelIdLength: 20,
    menuFontsize: "14px",
    menuMarginLeft: "3px",
    menuPadding: "3px 4px 3px 4px",
    menuItemFontsize: "14px",
    menuItemLineHeight: "14px"
  };

  // init msa
  var m = msa(opts);

  m.seqs.reset(seqs);
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
