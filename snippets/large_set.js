var opts = {};
opts.seqs = msa.utils.seqgen.getDummySequences(1000,300);
opts.el = yourDiv;
opts.vis = {conserv: false, overviewbox: false}
opts.zoomer = {boxRectHeight: 1, boxRectWidth: 1, alignmentHeight: window.innerHeight * 0.8, labelWidth: 120,labelFontsize: "12px",labelIdLength: 50}
var m = new msa.msa(opts);

// the menu is independent to the MSA container
var menuOpts = {};
var menuDiv = document.createElement('div');
document.body.appendChild(menuDiv);
menuOpts.el = menuDiv;
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);
//defMenu.createMenu();

m.addView("menu", defMenu);

m.render();
