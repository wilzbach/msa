var opts = {};
opts.seqs = msa.utils.seqgen.getDummySequences(1000,300);
opts.el = yourDiv;
opts.vis = {metacell: true, overviewbox: true};
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
