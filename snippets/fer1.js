var msa = require("biojs-vis-msa");
var clustal = require("biojs-io-clustal");

menuDiv = document.createElement('div');
msaDiv = document.createElement('div');
yourDiv.appendChild(menuDiv);
yourDiv.appendChild(msaDiv);

// this is a way how you use a bundled file parser
clustal.read("./data/fer1.clustal", function(seqs){

  var opts = {};

  // set your custom properties
  // @see: https://github.com/greenify/biojs-vis-msa/tree/master/src/g 
  opts.seqs = seqs; //msa.utils.seqgen.getDummySequences(1000,300);
  opts.el = msaDiv;
  opts.vis = {conserv: false, overviewbox: false};
  opts.zoomer = {alignmentHeight: 225, labelWidth: 130,labelFontsize: "13px",labelIdLength: 20,   menuFontsize: "14px",menuMarginLeft: "3px", menuPadding: "3px 4px 3px 4px", menuItemFontsize: "14px", menuItemLineHeight: "14px"};

  // init msa
  var m = new msa.msa(opts);

  // the menu is independent to the MSA container
  var menuOpts = {};
  menuOpts.el = document.getElementById('div');
  menuOpts.msa = m;
  var defMenu = new msa.menu.defaultmenu(menuOpts);
  m.addView("menu", defMenu);

  // call render at the end to display the whole MSA
  m.render();


  // BioJS event system test
  //instance=m.g

  //defMenu.el.style.marginTop = "15px";
  //defMenu.el.style.marginBottom = "25px";
});
