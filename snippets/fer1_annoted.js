
/* global yourDiv */
var msa = require("biojs-vis-msa");
var clustal = require("biojs-io-clustal");
var gffParser = require("biojs-io-gff");
var xhr = require("xhr");

// set your custom properties
// @see: https://github.com/greenify/biojs-vis-msa/tree/master/src/g 

var menuDiv = document.createElement('div');
var msaDiv = document.createElement('div');
yourDiv.appendChild(menuDiv);
yourDiv.appendChild(msaDiv);

var opts = {
  el: msaDiv
};
var url = "./data/fer1.clustal";

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

// download the sequences itself
clustal.read(url, function(seqs) {
  m.seqs.reset(seqs);
  m.render();
});

// add features
xhr("./data/fer1.gff3", function(err, request, body) {
  var features = gffParser.parseSeqs(body);
  m.seqs.addFeatures(features);
});

xhr("./data/fer1.gff_jalview", function(err, request, body) {
  var features = gffParser.parseSeqs(body);
  m.seqs.addFeatures(features);
});

// the menu is independent to the MSA container
var defMenu = new msa.menu.defaultmenu({
  el: menuDiv,
  msa: m
});
defMenu.render();

// BioJS event system test (you can safely remove this in your app)
//instance=m.g
