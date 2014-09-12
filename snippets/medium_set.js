var opts = {};
opts.seqs = msa.utils.seqgen.getDummySequences(300,300);
opts.el = yourDiv;
opts.vis = {metacell: true, overviewbox: true};
opts.zoomer = {boxRectHeight: 1, boxRectWidth: 1}
var m = new msa.msa(opts);

// the menu is independent to the MSA container
var menuOpts = {};
var menuDiv = document.createElement('div');
document.body.appendChild(menuDiv);
menuOpts.el = menuDiv;
menuOpts.msa = m;
var defMenu = new msa.menu.defaultmenu(menuOpts);

m.addView("menu", defMenu);
m.render();
