var msa = new biojs.vis.msa.msa('msa_menu');
msa.seqmgr.addDummySequences();

// the menu is independent to the MSA container
var defMenu = new biojs.vis.msa.menu.defaultmenu("msa_menubar", msa);
defMenu.createMenu();
